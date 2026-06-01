import React from "react";
import { DimensionValue, StyleSheet, Text, View } from "react-native";
import { upgrades } from "../data/balancing";
import { useGameStore } from "../store/gameStore";
import { colors } from "../theme";
import { cost, shortMoney } from "../utils/economy";
import { BuyButton, Card, Panel } from "./Panel";

export function UpgradesMenu({ onClose }: { onClose: () => void }) {
  const money = useGameStore((state) => state.money);
  const levels = useGameStore((state) => state.upgrades);
  const buyUpgrade = useGameStore((state) => state.buyUpgrade);

  return (
    <Panel title="Upgrades" subtitle="Verbessere Durchsatz, Preise und Kapazitaet." onClose={onClose}>
      {upgrades.map((upgrade) => {
        const level = levels[upgrade.id];
        const price = cost(upgrade.baseCost, upgrade.growth, level);
        const maxed = level >= upgrade.maxLevel;
        const width = `${Math.min(100, (level / upgrade.maxLevel) * 100)}%` as DimensionValue;
        return (
          <Card key={upgrade.id}>
            <View style={styles.header}>
              <Text style={styles.icon}>{upgrade.icon}</Text>
              <View style={styles.body}>
                <View style={styles.titleRow}>
                  <Text style={styles.title}>{upgrade.title}</Text>
                  <Text style={styles.level}>Lv {level}</Text>
                </View>
                <Text style={styles.description}>{upgrade.description}</Text>
              </View>
            </View>
            <View style={styles.progress}>
              <View style={[styles.progressFill, { width }]} />
            </View>
            <View style={styles.footer}>
              <Text style={styles.max}>Max Lv {upgrade.maxLevel}</Text>
              <BuyButton label={maxed ? "Max" : shortMoney(price)} disabled={maxed || money < price} onPress={() => buyUpgrade(upgrade.id)} />
            </View>
          </Card>
        );
      })}
    </Panel>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: "row",
    gap: 12
  },
  icon: {
    width: 44,
    height: 44,
    borderRadius: 14,
    color: colors.gold,
    backgroundColor: colors.panel3,
    textAlign: "center",
    textAlignVertical: "center",
    fontSize: 24,
    fontWeight: "900"
  },
  body: {
    flex: 1
  },
  titleRow: {
    flexDirection: "row",
    justifyContent: "space-between"
  },
  title: {
    color: colors.text,
    fontSize: 16,
    fontWeight: "900"
  },
  level: {
    color: colors.cyan,
    fontSize: 13,
    fontWeight: "900"
  },
  description: {
    color: colors.muted,
    fontSize: 12,
    lineHeight: 17,
    marginTop: 4
  },
  progress: {
    height: 9,
    borderRadius: 9,
    overflow: "hidden",
    backgroundColor: "rgba(255,255,255,0.08)",
    marginTop: 12
  },
  progressFill: {
    height: 9,
    borderRadius: 9,
    backgroundColor: colors.pink
  },
  footer: {
    marginTop: 12,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center"
  },
  max: {
    color: colors.dim,
    fontSize: 12,
    fontWeight: "800"
  }
});
