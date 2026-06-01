import type {
  BuildingDefinition,
  MissionDefinition,
  StaffDefinition,
  UpgradeDefinition
} from "../types";

export const upgrades: UpgradeDefinition[] = [
  {
    id: "ticketPrice",
    title: "Ticketpreis",
    description: "Bessere Filme, bessere Sitze, hoehere Ticketpreise.",
    icon: "$",
    baseCost: 120,
    growth: 1.42,
    maxLevel: 50
  },
  {
    id: "serviceSpeed",
    title: "Service-Speed",
    description: "Kassen und Snacks arbeiten schneller.",
    icon: "⚡",
    baseCost: 150,
    growth: 1.38,
    maxLevel: 45
  },
  {
    id: "visitorFlow",
    title: "Besucheranzahl",
    description: "Neonwerbung und bessere Lage bringen mehr Gaeste.",
    icon: "👥",
    baseCost: 180,
    growth: 1.45,
    maxLevel: 45
  },
  {
    id: "snackProfit",
    title: "Snackgewinn",
    description: "Popcorn, Drinks und Candy werden profitabler.",
    icon: "🍿",
    baseCost: 160,
    growth: 1.4,
    maxLevel: 50
  },
  {
    id: "hallCapacity",
    title: "Saalkapazitaet",
    description: "Mehr Sitze bedeuten weniger Besucher gehen verloren.",
    icon: "🎬",
    baseCost: 240,
    growth: 1.5,
    maxLevel: 40
  }
];

export const buildings: BuildingDefinition[] = [
  {
    id: "ticketBooth",
    title: "Ticketschalter",
    description: "Mehr Schalter verkleinern Warteschlangen.",
    icon: "🎟",
    baseCost: 450,
    growth: 1.75,
    maxCount: 5
  },
  {
    id: "popcornStand",
    title: "Popcorn-Stand",
    description: "Mehr Snacklinien verkaufen an hungrige Besucher.",
    icon: "🍿",
    baseCost: 500,
    growth: 1.72,
    maxCount: 4
  },
  {
    id: "cinemaHall",
    title: "Kinosaal",
    description: "Mehr Saele erhoehen Kapazitaet und Durchsatz.",
    icon: "🎥",
    baseCost: 900,
    growth: 1.85,
    maxCount: 6
  },
  {
    id: "drinkStand",
    title: "Getraenkestand",
    description: "Extra Umsatz pro Snackkunde.",
    icon: "🥤",
    baseCost: 1400,
    growth: 1.82,
    maxCount: 3
  },
  {
    id: "candyShop",
    title: "Candy-Shop",
    description: "Mehr Gewinn bei Familien und Teenagern.",
    icon: "🍬",
    baseCost: 2800,
    growth: 1.9,
    maxCount: 3
  },
  {
    id: "vipHall",
    title: "VIP-Saal",
    description: "Luxusgaeste zahlen deutlich mehr.",
    icon: "👑",
    baseCost: 8500,
    growth: 2.05,
    maxCount: 2
  },
  {
    id: "premiumLounge",
    title: "Premium Lounge",
    description: "Steigert Snackgewinn und Kundenzufriedenheit.",
    icon: "✨",
    baseCost: 15000,
    growth: 2.1,
    maxCount: 2
  }
];

export const staff: StaffDefinition[] = [
  {
    id: "cashier",
    title: "Kassierer",
    description: "Tickets werden schneller verkauft.",
    icon: "🧾",
    baseCost: 350,
    growth: 1.55,
    maxCount: 8
  },
  {
    id: "popcornPro",
    title: "Popcorn-Profi",
    description: "Snacks gehen schneller ueber die Theke.",
    icon: "🍿",
    baseCost: 500,
    growth: 1.6,
    maxCount: 7
  },
  {
    id: "usher",
    title: "Einweiser",
    description: "Besucher finden schneller zum Saal.",
    icon: "🔦",
    baseCost: 750,
    growth: 1.65,
    maxCount: 6
  },
  {
    id: "manager",
    title: "Manager",
    description: "Alle Einnahmen steigen dauerhaft.",
    icon: "💼",
    baseCost: 2200,
    growth: 1.9,
    maxCount: 5
  }
];

export const missions: MissionDefinition[] = [
  {
    id: "earnFirstCash",
    title: "Erste Abendkasse",
    description: "Verdiene insgesamt 1.000$.",
    target: 1000,
    reward: 250,
    metric: "money"
  },
  {
    id: "serveVisitors",
    title: "Volle Lobby",
    description: "Bediene 60 Besucher.",
    target: 60,
    reward: 450,
    metric: "visitors"
  },
  {
    id: "sellSnacks",
    title: "Popcorn-Duft",
    description: "Verkaufe 40 Snacks.",
    target: 40,
    reward: 600,
    metric: "snacks"
  },
  {
    id: "upgradeService",
    title: "Schneller Service",
    description: "Erreiche Service-Speed Level 5.",
    target: 5,
    reward: 900,
    metric: "service"
  },
  {
    id: "expandCinema",
    title: "Kinoausbau",
    description: "Besitze 7 Gebaeude insgesamt.",
    target: 7,
    reward: 1400,
    metric: "buildings"
  },
  {
    id: "reachWealth",
    title: "Mini-Imperium",
    description: "Verdiene insgesamt 25.000$.",
    target: 25000,
    reward: 4000,
    metric: "money"
  }
];

