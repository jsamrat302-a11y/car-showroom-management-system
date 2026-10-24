# VIVA EXPLANATION SCRIPT
## Car Showroom Management System — ER Diagram

*(Practice reading this out loud 2-3 times. Point at your diagram as you speak.)*

---

**1. AIM (10 sec)**
"My project is an ER diagram design for a Car Showroom Management System. The aim is to identify the entities, attributes, relationships, keys, and cardinalities needed to manage a showroom's suppliers, vehicle stock, and customer sales."

---

**2. SCENARIO (20 sec)**
"The system tracks how vehicles move from supplier to customer. Suppliers deliver vehicles, which get stored in inventory categorized by model. Customers then visit a showroom branch and place orders, which get fulfilled from that inventory. The system needs to track deliveries, stock, and orders efficiently."

---

**3. ENTITIES — walk left to right through the flow (1 min)**

"Supplier — stores who supplies the vehicles."

"Vehicle Delivery — a transaction record of vehicles arriving from a supplier."

"Vehicle Inventory — the actual stock currently held, with status like available or sold."

"Vehicle Model — categorizes vehicles by model, fuel type, category."

"Sales Order — a customer's request to buy a vehicle."

"Customer — the buyer."

"Showroom Branch — the branch through which the order is placed."

*(Mention one or two attribute types)*
"Supplier has multivalued attributes like Email and Phone Number, since a company can have more than one. Years In Business is a derived attribute — I calculate it from the establishment date rather than storing it directly."

---

**4. RELATIONSHIPS & CARDINALITY (40 sec)**

"Supplier to Vehicle Delivery is 1:M, since one supplier can make many deliveries."

"Vehicle Delivery to Inventory is M:1 — several deliveries feed into stock."

"Inventory to Sales Order is 1:M — one inventory item can be requested but should only be fulfilled once."

"Customer to Sales Order is also 1:M, since a customer can place multiple orders."

---

**5. KEYS (15 sec)**

"Each entity has its own primary key — like Supplier_ID, Customer_ID — and foreign keys tie the relationships together, like Sales_Order referencing Customer_ID, Branch_ID, and Inventory_ID."

---

**6. CONCLUSION (10 sec)**

"Overall, the design ensures efficient tracking of procurement, stock, and sales while maintaining data integrity through primary keys, foreign keys, and proper relationship constraints between entities."

---

## QUICK TIPS
- Point at the diagram as you talk — don't recite from memory.
- If asked "why this entity and not that one" — Delivery vs Inventory are separate because Delivery is a historical transaction, Inventory is current state.
- Speak in terms of the real-world flow (supplier → stock → customer) before jumping into technical terms.
