ShoulderMap := Map(
    "chuck", ["bone-in", "boneless"]
    ; add weight....
)

listOfParts := Map(
    "Beef", Map(
        "_listA", Map(
            "Shoulder", ShoulderMap,
            "Arm", Map(
                "Bone-in", Map(
                    "Roasts", Map(
                        "Weight", ["2-3 lbs", "3-4 lbs", "4-5 lbs", "1-2 lbs"]
                    )
                ),
                "Boneless", Map(
                    "Roasts", Map(
                        "Weight", ["2-3 lbs", "3-4 lbs", "4-5 lbs", "1-2 lbs"]
                    )
                )
            ),
            "Brisket", ["Grind", "Whole", "Halved", "Quartered"],
            "Shanks", Map(
                "Grind", [],
                "Whole", [],
                "Shank Cuts", Map(
                    "Thickness", ["2in", "1.5in", "1in"]
                )
            ),
            "Skirt", ["Grind", "Steak"],
            "Bones", Map(
                "No", [],
                "Marrow Only", [],
                "Knuckles Only", [],
                "Marrows & Knuckles", []
            ),
            "Ribs", Map(
                "Short Ribs", ["Grind", "Plate", "English", "Korean"]
            ),
            "Ribeye", Map(
                "Grind", [],
                "Bone-in", ["Steaks", "Roasts"],
                "Boneless", ["Steaks", "Roasts"],
                "Steaks", Map(
                    "Thickness", ["1.5in", "1in", "1.25in", "1.75in", "0.75in"]
                ),
                "Tomahawks", ["No", "Yes"],
                "No./Pack", ["2", "1 (1 steak per pack charged by side)"],
                "Roasts", Map(
                    "Size", ["Halved", "Whole", "Thirds"]
                ),
                "Frenched", ["No", "Yes (Charged per side)"]
            ),
            "Loin", Map(
                "Hanger", ["Grind", "Steak"],
                "Flank", ["Grind", "Steak"]
            ),
            "Steaks", Map(
                "Grind", [],
                "N.Y. Strip/Filet Mignon/Top Sirloin", Map(
                    "N.Y. Strip", Map(
                        "Thickness", ["1.5in", "1in", "1.25in", "1.75in", "0.75in"],
                        "No./Pack", ["2", "3", "4", "1"]
                    ),
                    "Filet Mignon", Map(
                        "Thickness", ["1.5in", "1in", "1.25in", "1.75in", "0.75in"],
                        "No./Pack", ["2", "3", "4", "1"]
                    ),
                    "Top Sirloin", Map(
                        "Thickness", ["1.5in", "1in", "1.25in", "1.75in", "0.75in"]
                    )
                ),
                "T-bone/Porterhouse/Bone-in Sirloin", Map(
                    "T-bone/Porterhouse", Map(
                        "Thickness", ["1.5in", "1in", "1.25in", "1.75in", "0.75in"],
                        "No./Pack", ["2", "3", "4", "1"]
                    ),
                    "Bone-in Sirloin", Map(
                        "Thickness", ["1.5in", "1in", "1.25in", "1.75in", "0.75in"]
                    )
                )
            ),
            "Round", Map(
                "London Broil", ["Grind", "Roasts", "Steaks", "Stew Meat", "Fajita", "Kabob", "Cube Steak", "Thinly Sliced"],
                "Top Round", ["Grind", "Roasts", "Steaks", "Stew Meat", "Fajita", "Kabob", "Cube Steak", "Thinly Sliced"],
                "Bottom Round", ["Grind", "Roasts", "Steaks", "Stew Meat", "Fajita", "Kabob", "Cube Steak", "Thinly Sliced"],
                "Eye of Round", ["Grind", "Roasts", "Steaks", "Stew Meat", "Fajita", "Kabob", "Cube Steak", "Thinly Sliced"],
                "Sirloin Tip", ["Grind", "Roasts", "Steaks", "Stew Meat", "Fajita", "Kabob", "Cube Steak", "Thinly Sliced"]
            ),
            "Ground", Map(
                "Trim Packed Unground", Map(
                    "No", [],
                    "Yes", ["Ranged input value by customer (10 lbs to 1000 lbs)"]
                ),
                "Ground Beef", Map(
                    "1 lb", ["100% 1 lb", "2 lbs (50%)", "5 lbs (50%)", "10 lbs (50%)"],
                    "2 lbs", ["100% 2 lbs", "1 lb (50%)", "5 lbs (50%)", "10 lbs (50%)"],
                    "5 lbs", ["100% 5 lbs", "1 lb (50%)", "2 lbs (50%)", "10 lbs (50%)"],
                    "10 lbs", ["100% 10 lbs", "1 lb (50%)", "2 lbs (50%)", "5 lbs (50%)"]
                ),
                "Beef Patties", Map(
                    "None", [],
                    "25 lbs", Map("Weight", ["4oz", "5oz", "6oz"]),
                    "50 lbs", Map("Weight", ["4oz", "5oz", "6oz"]),
                    "75 lbs", Map("Weight", ["4oz", "5oz", "6oz"]),
                    "100 lbs", Map("Weight", ["4oz", "5oz", "6oz"])
                )
            ),
            "Offal", Map(
                "Heart", Map("No", [], "Yes", []),
                "Liver", Map(
                    "No", [],
                    "Whole", [],
                    "Roasts", [],
                    "Sliced", Map("Roasts", ["2-3 lbs", "3-4 lbs", "4-5 lbs", "1-2 lbs"])
                ),
                "Kidney", Map("No", [], "Yes", []),
                "Tongue", Map("No", [], "Yes", []),
                "Oxtail", Map("No", [], "Yes", []),
                "Beef Back Fat", Map("No", [], "Yes", []),
                "Beef Kidney Fat", Map("No", [], "Yes", [])
            ),
            "Beef Modern Boneless", []
        )
    )
)