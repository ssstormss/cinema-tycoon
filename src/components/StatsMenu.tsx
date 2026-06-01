import React from "react";
import { StyleSheet, Text, View } from "react-native";
import { useGameStore } from "../store/gameStore";
import { colors } from "../theme";
import {
  estimatedIncomePerMinute,
  hallCapacity,
  shortMoney,
  snackServicePerSecond,
  snackValue,
  ticketServicePerSecond,
  ticketValue,
  totalBuildings,
  visitorRate
} from "../utils/economy";
import { Card, Panel } from "./Panel";

export function StatsMenu({ onClose }: { onClose: () => void }) {
  const stats = useGameStore((state) => state.stats);
  const upgrades = useGameStore((state) => state.upgrades);
  const buildings = useGameStore((state) => state.buildings);
  const staff = useGameStore((state) => state.staff);
  const occupiedSeats = useGameStore((state) => state.occupiedSeats);

  const rows = [
    ["Total earned", shortMoney(stats.totalEarned)],
    ["Income / min", shortMoney(estimatedIncomePerMinute(upgrades, staff, buildings))],
    ["Ticket value", shortMoney(ticketValue(upgrades, staff, buildings))],
    ["Snack value", shortMoney(snackValue(upgrades, staff, buildings))],
    ["Visitor flow", `${(visitorRate(upgrades, buildings) * 60).toFixed(1)} / min`],
    ["Ticket service", `${ticketServicePerSecond(upgrades, staff, buildings).toFixed(2)} / sec`],
    ["Snack service", `${snackServicePerSecond(upgrades, staff, buildings).toFixed(2)} / sec`],
    ["Seats", `${occupiedSeats}/${hallCapacity(upgrades, buildings, staff)}`],
    ["Buildings", `${totalBuildings(buildings)}`],
    ["Tickets sold", `${stats.ticketsSold}`],
    ["Snacks sold", `${stats.snacksSold}`],
    ["Play time", `${Math.floor(stats.playSeconds / 60)} min`]
  ];

  return (
    <Panel title="Statistics" subtitle="Dein Kino in Zahlen." onClose={onClose}>
      <Card>
        {rows.map(([label, value]) => (
          <View style={styles.row} key={label}>
            <Text style={styles.label}>{label}</Text>
            <Text style={styles.value}>{value}</Text>
          </View>
        ))}
      </Card>
    </Panel>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingVertical: 9,
    borderBottomColor: "rgba(255,255,255,0.07)",
    borderBottomWidth: 1
  },
  label: {
    color: colors.muted,
    fontSize: 13,
    fontWeight: "800"
  },
  value: {
    color: colors.gold,
    fontSize: 14,
    fontWeight: "900"
  }
});

