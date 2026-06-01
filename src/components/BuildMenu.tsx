import React from "react";
import { StyleSheet, Text, View } from "react-native";
import { buildings, staff } from "../data/balancing";
import { useGameStore } from "../store/gameStore";
import { colors } from "../theme";
import { cost, shortMoney } from "../utils/economy";
import { BuyButton, Card, Panel } from "./Panel";

export function BuildMenu({ onClose }: { onClose: () => void }) {
  const money = useGameStore((state) => state.money);
  const counts = useGameStore((state) => state.buildings);
  const staffCounts = useGameStore((state) => state.staff);
  const buyBuilding = useGameStore((state) => state.buyBuilding);
  const hireStaff = useGameStore((state) => state.hireStaff);

  return (
    <Panel title="Build" subtitle="Erweitere dein Kino mit neuen Umsatzstationen." onClose={onClose}>
      <Text style={styles.section}>Buildings</Text>
      {buildings.map((building) => {
        const owned = counts[building.id];
        const price = cost(building.baseCost, building.growth, owned);
        const maxed = owned >= building.maxCount;
        return (
          <Card key={building.id}>
            <View style={styles.row}>
              <View style={styles.iconBox}>
                <Text style={styles.icon}>{building.icon}</Text>
              </View>
              <View style={styles.body}>
                <View style={styles.titleRow}>
                  <Text style={styles.title}>{building.title}</Text>
                  <Text style={styles.count}>x{owned}</Text>
                </View>
                <Text style={styles.description}>{building.description}</Text>
              </View>
            </View>
            <View style={styles.footer}>
              <Text style={styles.max}>Max {building.maxCount}</Text>
              <BuyButton label={maxed ? "Max" : shortMoney(price)} disabled={maxed || money < price} onPress={() => buyBuilding(building.id)} />
            </View>
          </Card>
        );
      })}

      <Text style={styles.section}>Staff</Text>
      {staff.map((member) => {
        const owned = staffCounts[member.id];
        const price = cost(member.baseCost, member.growth, owned);
        const maxed = owned >= member.maxCount;
        return (
          <Card key={member.id}>
            <View style={styles.row}>
              <View style={styles.iconBox}>
                <Text style={styles.icon}>{member.icon}</Text>
              </View>
              <View style={styles.body}>
                <View style={styles.titleRow}>
                  <Text style={styles.title}>{member.title}</Text>
                  <Text style={styles.count}>x{owned}</Text>
                </View>
                <Text style={styles.description}>{member.description}</Text>
              </View>
            </View>
            <View style={styles.footer}>
              <Text style={styles.max}>Max {member.maxCount}</Text>
              <BuyButton label={maxed ? "Max" : shortMoney(price)} disabled={maxed || money < price} onPress={() => hireStaff(member.id)} />
            </View>
          </Card>
        );
      })}
    </Panel>
  );
}

const styles = StyleSheet.create({
  section: {
    color: colors.gold,
    fontSize: 13,
    fontWeight: "900",
    textTransform: "uppercase",
    letterSpacing: 1,
    marginTop: 4
  },
  row: {
    flexDirection: "row",
    gap: 12
  },
  iconBox: {
    width: 48,
    height: 48,
    borderRadius: 16,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: colors.panel3
  },
  icon: {
    fontSize: 25
  },
  body: {
    flex: 1
  },
  titleRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center"
  },
  title: {
    color: colors.text,
    fontSize: 16,
    fontWeight: "900"
  },
  count: {
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
  footer: {
    marginTop: 12,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center"
  },
  max: {
    color: colors.dim,
    fontWeight: "800",
    fontSize: 12
  }
});

