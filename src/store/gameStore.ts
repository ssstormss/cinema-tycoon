import AsyncStorage from "@react-native-async-storage/async-storage";
import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";
import { buildings, missions, staff, upgrades } from "../data/balancing";
import type { BuildingId, EarningsPopup, GameStats, MissionId, StaffId, UpgradeId, Visitor, VisitorPhase } from "../types";
import {
  cost,
  estimatedIncomePerMinute,
  hallCapacity,
  snackServicePerSecond,
  snackValue,
  startingBuildings,
  startingStaff,
  startingUpgrades,
  ticketServicePerSecond,
  ticketValue,
  totalBuildings,
  visitorRate
} from "../utils/economy";

interface GameStore {
  money: number;
  offlineReward: number;
  ticketQueue: number;
  snackQueue: number;
  occupiedSeats: number;
  visitorSpawnBank: number;
  ticketServiceBank: number;
  snackServiceBank: number;
  seatReleaseBank: number;
  visitors: Visitor[];
  earningsPopups: EarningsPopup[];
  upgrades: Record<UpgradeId, number>;
  buildings: Record<BuildingId, number>;
  staff: Record<StaffId, number>;
  claimedMissions: MissionId[];
  stats: GameStats;
  lastSavedAt: number;
  tick: (deltaSeconds: number) => void;
  hydrateClock: () => void;
  clearOfflineReward: () => void;
  buyUpgrade: (id: UpgradeId) => boolean;
  buyBuilding: (id: BuildingId) => boolean;
  hireStaff: (id: StaffId) => boolean;
  claimMission: (id: MissionId) => boolean;
  resetGame: () => void;
}

const colors = ["#4cc9f0", "#ff4fd8", "#06d6a0", "#ffd166", "#9b5de5", "#ef476f"];

function freshStats(): GameStats {
  return {
    totalEarned: 0,
    visitorsServed: 0,
    snacksSold: 0,
    ticketsSold: 0,
    playSeconds: 0
  };
}

function createVisitor(index: number): Visitor {
  return {
    id: `${Date.now()}-${Math.round(Math.random() * 1_000_000)}`,
    lane: index % 5,
    phase: "entering",
    progress: 0,
    wantsSnack: Math.random() < 0.58,
    color: colors[Math.floor(Math.random() * colors.length)] ?? "#4cc9f0"
  };
}

function advanceVisitors(visitors: Visitor[], deltaSeconds: number, ticketSlots: number, snackSlots: number, seats: number): Visitor[] {
  const ticketQueue = visitors.filter((visitor) => visitor.phase === "ticketQueue").length;
  const snackQueue = visitors.filter((visitor) => visitor.phase === "snackQueue").length;
  const watching = visitors.filter((visitor) => visitor.phase === "watchingMovie").length;

  const withPhase = (visitor: Visitor, phase: VisitorPhase, progress: number): Visitor => ({ ...visitor, phase, progress });

  return visitors
    .map((visitor) => {
      const speed = deltaSeconds * (visitor.phase === "watchingMovie" ? 0.08 : 0.34);
      const next = { ...visitor, progress: Math.min(1, visitor.progress + speed) };

      if (next.phase === "entering" && next.progress >= 1) {
        return withPhase(next, "ticketQueue", Math.min(0.25, ticketQueue * 0.04));
      }
      if (next.phase === "ticketQueue" && ticketSlots > 0) {
        ticketSlots -= 1;
        return withPhase(next, "buyingTicket", 0);
      }
      if (next.phase === "buyingTicket" && next.progress >= 1) {
        if (next.wantsSnack) {
          return withPhase(next, "snackQueue", Math.min(0.2, snackQueue * 0.04));
        }
        if (watching < seats) {
          return withPhase(next, "watchingMovie", 0);
        }
        return withPhase(next, "leaving", 0);
      }
      if (next.phase === "snackQueue" && snackSlots > 0) {
        snackSlots -= 1;
        return withPhase(next, "buyingSnack", 0);
      }
      if (next.phase === "buyingSnack" && next.progress >= 1) {
        if (watching < seats) {
          return withPhase(next, "watchingMovie", 0);
        }
        return withPhase(next, "leaving", 0);
      }
      if (next.phase === "watchingMovie" && next.progress >= 1) {
        return withPhase(next, "leaving", 0);
      }
      return next;
    })
    .filter((visitor) => !(visitor.phase === "leaving" && visitor.progress >= 1))
    .slice(-34);
}

function initialState() {
  return {
    money: 500,
    offlineReward: 0,
    ticketQueue: 0,
    snackQueue: 0,
    occupiedSeats: 0,
    visitorSpawnBank: 0,
    ticketServiceBank: 0,
    snackServiceBank: 0,
    seatReleaseBank: 0,
    visitors: [] as Visitor[],
    earningsPopups: [] as EarningsPopup[],
    upgrades: { ...startingUpgrades },
    buildings: { ...startingBuildings },
    staff: { ...startingStaff },
    claimedMissions: [] as MissionId[],
    stats: freshStats(),
    lastSavedAt: Date.now()
  };
}

export const useGameStore = create<GameStore>()(
  persist(
    (set, get) => ({
      ...initialState(),
      tick: (deltaSeconds) => {
        const state = get();
        const safeDelta = Math.min(Math.max(deltaSeconds, 0), 5);
        const spawnBank = state.visitorSpawnBank + visitorRate(state.upgrades, state.buildings) * safeDelta;
        const ticketBank = state.ticketServiceBank + ticketServicePerSecond(state.upgrades, state.staff, state.buildings) * safeDelta;
        const snackBank = state.snackServiceBank + snackServicePerSecond(state.upgrades, state.staff, state.buildings) * safeDelta;
        let newVisitors = [...state.visitors];
        let remainingSpawnBank = spawnBank;

        while (remainingSpawnBank >= 1 && newVisitors.length < 34) {
          newVisitors.push(createVisitor(newVisitors.length));
          remainingSpawnBank -= 1;
        }

        const ticketSlots = Math.floor(ticketBank);
        const snackSlots = Math.floor(snackBank);
        const beforeTickets = newVisitors.filter((visitor) => visitor.phase === "buyingTicket").length;
        const beforeSnacks = newVisitors.filter((visitor) => visitor.phase === "buyingSnack").length;
        newVisitors = advanceVisitors(
          newVisitors,
          safeDelta,
          ticketSlots,
          snackSlots,
          hallCapacity(state.upgrades, state.buildings, state.staff)
        );
        const afterTicketBuyers = newVisitors.filter((visitor) => visitor.phase === "buyingTicket").length;
        const afterSnackBuyers = newVisitors.filter((visitor) => visitor.phase === "buyingSnack").length;
        const completedTickets = Math.max(0, beforeTickets - afterTicketBuyers + Math.floor(ticketSlots * 0.35));
        const completedSnacks = Math.max(0, beforeSnacks - afterSnackBuyers + Math.floor(snackSlots * 0.3));
        const ticketIncome = completedTickets * ticketValue(state.upgrades, state.staff, state.buildings);
        const snackIncome = completedSnacks * snackValue(state.upgrades, state.staff, state.buildings);
        const earned = ticketIncome + snackIncome;
        const now = Date.now();
        const popups = [
          ...state.earningsPopups.filter((popup) => now - popup.createdAt < 1800),
          ...(ticketIncome > 0
            ? [
                {
                  id: `ticket-${now}-${Math.random()}`,
                  amount: ticketIncome,
                  x: 0.31,
                  y: 0.58,
                  createdAt: now
                }
              ]
            : []),
          ...(snackIncome > 0
            ? [
                {
                  id: `snack-${now}-${Math.random()}`,
                  amount: snackIncome,
                  x: 0.69,
                  y: 0.58,
                  createdAt: now
                }
              ]
            : [])
        ].slice(-8);

        set({
          visitors: newVisitors,
          earningsPopups: popups,
          money: state.money + earned,
          visitorSpawnBank: remainingSpawnBank,
          ticketServiceBank: ticketBank - ticketSlots,
          snackServiceBank: snackBank - snackSlots,
          ticketQueue: newVisitors.filter((visitor) => visitor.phase === "ticketQueue").length,
          snackQueue: newVisitors.filter((visitor) => visitor.phase === "snackQueue").length,
          occupiedSeats: newVisitors.filter((visitor) => visitor.phase === "watchingMovie").length,
          stats: {
            ...state.stats,
            totalEarned: state.stats.totalEarned + earned,
            visitorsServed: state.stats.visitorsServed + completedTickets,
            ticketsSold: state.stats.ticketsSold + completedTickets,
            snacksSold: state.stats.snacksSold + completedSnacks,
            playSeconds: state.stats.playSeconds + safeDelta
          },
          lastSavedAt: now
        });
      },
      hydrateClock: () => {
        const state = get();
        const elapsed = Math.min(8 * 60 * 60, Math.max(0, (Date.now() - state.lastSavedAt) / 1000));
        if (elapsed < 20) return;
        const reward = (estimatedIncomePerMinute(state.upgrades, state.staff, state.buildings) / 60) * elapsed * 0.38;
        set({
          money: state.money + reward,
          offlineReward: reward,
          stats: {
            ...state.stats,
            totalEarned: state.stats.totalEarned + reward
          },
          lastSavedAt: Date.now()
        });
      },
      clearOfflineReward: () => set({ offlineReward: 0 }),
      buyUpgrade: (id) => {
        const state = get();
        const definition = upgrades.find((item) => item.id === id);
        if (!definition) return false;
        const level = state.upgrades[id];
        const price = cost(definition.baseCost, definition.growth, level);
        if (level >= definition.maxLevel || state.money < price) return false;
        set({
          money: state.money - price,
          upgrades: { ...state.upgrades, [id]: level + 1 },
          lastSavedAt: Date.now()
        });
        return true;
      },
      buyBuilding: (id) => {
        const state = get();
        const definition = buildings.find((item) => item.id === id);
        if (!definition) return false;
        const owned = state.buildings[id];
        const price = cost(definition.baseCost, definition.growth, owned);
        if (owned >= definition.maxCount || state.money < price) return false;
        set({
          money: state.money - price,
          buildings: { ...state.buildings, [id]: owned + 1 },
          lastSavedAt: Date.now()
        });
        return true;
      },
      hireStaff: (id) => {
        const state = get();
        const definition = staff.find((item) => item.id === id);
        if (!definition) return false;
        const owned = state.staff[id];
        const price = cost(definition.baseCost, definition.growth, owned);
        if (owned >= definition.maxCount || state.money < price) return false;
        set({
          money: state.money - price,
          staff: { ...state.staff, [id]: owned + 1 },
          lastSavedAt: Date.now()
        });
        return true;
      },
      claimMission: (id) => {
        const state = get();
        const mission = missions.find((item) => item.id === id);
        if (!mission || state.claimedMissions.includes(id)) return false;
        const progress =
          mission.metric === "money"
            ? state.stats.totalEarned
            : mission.metric === "visitors"
              ? state.stats.visitorsServed
              : mission.metric === "snacks"
                ? state.stats.snacksSold
                : mission.metric === "service"
                  ? state.upgrades.serviceSpeed
                  : totalBuildings(state.buildings);
        if (progress < mission.target) return false;
        set({
          money: state.money + mission.reward,
          claimedMissions: [...state.claimedMissions, id],
          lastSavedAt: Date.now()
        });
        return true;
      },
      resetGame: () => set(initialState())
    }),
    {
      name: "cinema-empire-tycoon-save-v1",
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        money: state.money,
        upgrades: state.upgrades,
        buildings: state.buildings,
        staff: state.staff,
        claimedMissions: state.claimedMissions,
        stats: state.stats,
        lastSavedAt: state.lastSavedAt
      })
    }
  )
);
