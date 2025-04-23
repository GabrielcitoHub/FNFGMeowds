local itemList = {}
table.insert(itemList, {id = "Milk",
                        desc = "Tasty, chance of getting double health on note hit.",
                        price = 50})
table.insert(itemList, {id = "Water",
                        desc = "Hydratating, 1% chance of healing on low hp.",
                        price = 20})
table.insert(itemList, {id = "Cola",
                        desc = "Energizating, 25% chance of losing less health on miss",
                        price = 75})
return itemList