import React from "react";
import { StyleSheet, Text, View } from "react-native";
import { useGameStore } from "../store/gameStore";
import { colors } from "../theme";
import { shortMoney } from "../utils/economy";

export function GameHud() {
  const money = useGameStore((state) => state.money);
  const visitors = useGameStore((state) => state.stats.visitorsServed);
  const ticketQueue = useGameStore((state) => state.ticketQueue);
  const snackQueue = useGameStore((state) => state.snackQueue);

  return (
    <View style={styles.container}>
      <View>
        <Text style={styles.title}>Cinema Empire</Text>
        <Text style={styles.subtitle}>Neon Lobby Tycoon</Text>
      </View>
      <View style={styles.metrics}>
        <View style={styles.pill}>
          <Text style={styles.pillLabel}>Cash</Text>
          <Text style={styles.money}>{shortMoney(money)}</Text>
        </View>
        <View style={styles.pill}>
          <Text style={styles.pillLabel}>Visitors</Text>
          <Text style={styles.value}>{visitors}</Text>
        </View>
        <View style={styles.pill}>
          <Text style={styles.pillLabel}>Queue</Text>
          <Text style={styles.value}>{ticketQueue + snackQueue}</Text>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 16,
    paddingTop: 8,
    paddingBottom: 10,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    backgroundColor: "rgba(9,8,20,0.96)",
    borderBottomColor: "rgba(255,255,255,0.08)",
    borderBottomWidth: 1
  },
  title: {
    color: colors.text,
    fontSize: 22,
    fontWeight: "900",
    letterSpacing: 0.4
  },
  subtitle: {
    color: colors.muted,
    fontSize: 12,
    marginTop: 1
  },
  metrics: {
    flexDirection: "row",
    gap: 7
  },
  pill: {
    minWidth: 66,
    paddingHorizontal: 9,
    paddingVertical: 7,
    borderRadius: 12,
    backgroundColor: colors.panel2,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)"
  },
  pillLabel: {
    color: colors.dim,
    fontSize: 10,
    fontWeight: "700"
  },
  money: {
    color: colors.gold,
    fontSize: 14,
    fontWeight: "900"
  },
  value: {
    color: colors.cyan,
    fontSize: 14,
    fontWeight: "900"
  }
});

