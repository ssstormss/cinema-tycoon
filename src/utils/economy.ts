import { buildings, staff, upgrades } from "../data/balancing";
import type { BuildingId, StaffId, UpgradeId } from "../types";

export const startingBuildings: Record<BuildingId, number> = {
  ticketBooth: 1,
  popcornStand: 1,
  cinemaHall: 1,
  drinkStand: 0,
  candyShop: 0,
  vipHall: 0,
  premiumLounge: 0
};

export const startingUpgrades: Record<UpgradeId, number> = {
  ticketPrice: 1,
  serviceSpeed: 1,
  visitorFlow: 1,
  snackProfit: 1,
  hallCapacity: 1
};

export const startingStaff: Record<StaffId, number> = {
  cashier: 0,
  popcornPro: 0,
  usher: 0,
  manager: 0
};

export function shortMoney(value: number): string {
  const abs = Math.abs(value);
  if (abs >= 1_000_000_000) return `$${(value / 1_000_000_000).toFixed(2)}B`;
  if (abs >= 1_000_000) return `$${(value / 1_000_000).toFixed(2)}M`;
  if (abs >= 1_000) return `$${(value / 1_000).toFixed(1)}K`;
  return `$${Math.floor(value)}`;
}

export function cost(baseCost: number, growth: number, ownedOrLevel: number): number {
  return Math.floor(baseCost * Math.pow(growth, ownedOrLevel));
}

export function totalBuildings(counts: Record<BuildingId, number>): number {
  return Object.values(counts).reduce((sum, count) => sum + count, 0);
}

export function ticketValue(upgradeLevels: Record<UpgradeId, number>, staffCounts: Record<StaffId, number>, buildingCounts: Record<BuildingId, number>): number {
  const managerBonus = 1 + staffCounts.manager * 0.08;
  const vipBonus = 1 + buildingCounts.vipHall * 0.32;
  return (9 + upgradeLevels.ticketPrice * 3.5) * managerBonus * vipBonus;
}

export function snackValue(upgradeLevels: Record<UpgradeId, number>, staffCounts: Record<StaffId, number>, buildingCounts: Record<BuildingId, number>): number {
  const drinkBonus = 1 + buildingCounts.drinkStand * 0.22;
  const candyBonus = 1 + buildingCounts.candyShop * 0.28;
  const loungeBonus = 1 + buildingCounts.premiumLounge * 0.3;
  const managerBonus = 1 + staffCounts.manager * 0.05;
  return (5 + upgradeLevels.snackProfit * 2.75) * drinkBonus * candyBonus * loungeBonus * managerBonus;
}

export function visitorRate(upgradeLevels: Record<UpgradeId, number>, buildingCounts: Record<BuildingId, number>): number {
  const lounge = 1 + buildingCounts.premiumLounge * 0.12;
  return (0.28 + upgradeLevels.visitorFlow * 0.065) * lounge;
}

export function ticketServicePerSecond(upgradeLevels: Record<UpgradeId, number>, staffCounts: Record<StaffId, number>, buildingCounts: Record<BuildingId, number>): number {
  return buildingCounts.ticketBooth * (0.34 + upgradeLevels.serviceSpeed * 0.055 + staffCounts.cashier * 0.06);
}

export function snackServicePerSecond(upgradeLevels: Record<UpgradeId, number>, staffCounts: Record<StaffId, number>, buildingCounts: Record<BuildingId, number>): number {
  return buildingCounts.popcornStand * (0.22 + upgradeLevels.serviceSpeed * 0.035 + staffCounts.popcornPro * 0.055);
}

export function hallCapacity(upgradeLevels: Record<UpgradeId, number>, buildingCounts: Record<BuildingId, number>, staffCounts: Record<StaffId, number>): number {
  return buildingCounts.cinemaHall * (18 + upgradeLevels.hallCapacity * 5 + staffCounts.usher * 2) + buildingCounts.vipHall * 18;
}

export function estimatedIncomePerMinute(upgradeLevels: Record<UpgradeId, number>, staffCounts: Record<StaffId, number>, buildingCounts: Record<BuildingId, number>): number {
  const served = Math.min(
    visitorRate(upgradeLevels, buildingCounts) * 60,
    ticketServicePerSecond(upgradeLevels, staffCounts, buildingCounts) * 60,
    hallCapacity(upgradeLevels, buildingCounts, staffCounts)
  );
  return served * ticketValue(upgradeLevels, staffCounts, buildingCounts) + served * 0.52 * snackValue(upgradeLevels, staffCounts, buildingCounts);
}

export function findUpgrade(id: UpgradeId) {
  return upgrades.find((item) => item.id === id);
}

export function findBuilding(id: BuildingId) {
  return buildings.find((item) => item.id === id);
}

export function findStaff(id: StaffId) {
  return staff.find((item) => item.id === id);
}

