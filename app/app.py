"""
Car Showroom Management System  -  Flask + MySQL web app
Run from the project root:  python app/app.py
"""
import os
import re
from pathlib import Path

import pymysql
from flask import Flask, flash, g, redirect, render_template, request, url_for

ROOT = Path(__file__).resolve().parent.parent
LAB_FILE = ROOT / "docs" / "lab_record.md"

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "change-me-in-production")

DB = dict(
    host=os.getenv("DB_HOST", "localhost"),
    user=os.getenv("DB_USER", "showroom_app"),
    password=os.getenv("DB_PASSWORD", "ShowroomApp_123"),
    database=os.getenv("DB_NAME", "CarShowroomDB"),
    cursorclass=pymysql.cursors.DictCursor,
)

# --------------------------------------------------------------------
# One entry per table:  (column, label, input type)
# type  fk:Table.LabelColumn -> dropdown,  sel:a,b,c -> fixed choices
# --------------------------------------------------------------------
TABLES = {
    "supplier": dict(t="Supplier", pk="Supplier_ID", pre="S", title="Suppliers", cols=[
        ("Name", "Name", "text"), ("Company_Type", "Company type", "text"),
        ("Address", "Address", "text"), ("Est_Year", "Established year", "number")]),
    "model": dict(t="Vehicle_Model", pk="Model_ID", pre="M", title="Vehicle Models", cols=[
        ("Model_Name", "Model name", "text"), ("Fuel_Type", "Fuel type", "text"),
        ("Category", "Category", "text")]),
    "inventory": dict(t="Vehicle_Inventory", pk="Inventory_ID", pre="I", title="Inventory", cols=[
        ("Model_ID", "Model", "fk:Vehicle_Model.Model_Name"),
        ("Manufacture_Date", "Manufacture date", "date"),
        ("Status", "Status", "sel:Available,Reserved,Sold"), ("Location", "Location", "text")]),
    "delivery": dict(t="Vehicle_Delivery", pk="Delivery_ID", pre="D", title="Deliveries", cols=[
        ("Supplier_ID", "Supplier", "fk:Supplier.Name"),
        ("Inventory_ID", "Inventory unit", "fk:Vehicle_Inventory.Inventory_ID"),
        ("Delivery_Date", "Delivery date", "date"), ("Quantity", "Quantity", "number")]),
    "branch": dict(t="Showroom_Branch", pk="Branch_ID", pre="B", title="Branches", cols=[
        ("Name", "Name", "text"), ("Address", "Address", "text"),
        ("Contact_Number", "Contact number", "text")]),
    "customer": dict(t="Customer", pk="Customer_ID", pre="C", title="Customers", cols=[
        ("Branch_ID", "Branch", "fk:Showroom_Branch.Name"), ("Name", "Name", "text"),
        ("Gender", "Gender", "sel:Male,Female,Other"), ("Age", "Age", "number"),
        ("Phone_Number", "Phone number", "text")]),
    "order": dict(t="Sales_Order", pk="Order_ID", pre="O", title="Sales Orders", cols=[
        ("Customer_ID", "Customer", "fk:Customer.Name"), ("Branch_ID", "Branch", "fk:Showroom_Branch.Name"),
        ("Inventory_ID", "Vehicle", "fk:Vehicle_Inventory.Inventory_ID"),
        ("Order_Date", "Order date", "date"), ("Quantity_Required", "Quantity", "number"),
        ("Status", "Status", "sel:Pending,Confirmed,Fulfilled,Cancelled"),
        ("Total_Amount", "Total (Rs lakh)", "number")]),
}
PK_OF = {c["t"]: c["pk"] for c in TABLES.values()}


# --------------------------------------------------------------------
# Database helpers
# --------------------------------------------------------------------
def db():
    if "db" not in g:
        g.db = pymysql.connect(**DB)
    return g.db


@app.teardown_appcontext
def close_db(_):
    conn = g.pop("db", None)
    if conn:
        conn.close()


def query(sql, args=None):
    with db().cursor() as cur:
        cur.execute(sql, args)
        return list(cur.fetchall())


def call(proc, args=()):
    with db().cursor() as cur:
        cur.callproc(proc, args)
        return list(cur.fetchall())


def run(sql, args=None):
    with db().cursor() as cur:
        cur.execute(sql, args)


def err(e):
    return e.args[1] if len(e.args) > 1 else str(e)


def next_id(cfg):
    ids = [r[cfg["pk"]] for r in query(f"SELECT {cfg['pk']} FROM {cfg['t']}")]
    nums = [int(i[len(cfg["pre"]):]) for i in ids if i[len(cfg["pre"]):].isdigit()]
    return f"{cfg['pre']}{max(nums, default=0) + 1:02d}"


def fk_options(spec):
    table, col = spec.split(":")[1].split(".")
    pk = PK_OF[table]
    rows = query(f"SELECT {pk} AS id, {col} AS label FROM {table} ORDER BY {pk}")
    return [(r["id"], r["id"] if col == pk else f"{r['id']} - {r['label']}") for r in rows]


@app.context_processor
def inject():
    return dict(tables=TABLES)


# --------------------------------------------------------------------
# Pages
# --------------------------------------------------------------------
@app.route("/")
def home():
    count = lambda sql: query(sql)[0]["n"]
    stats = [
        ("Suppliers", count("SELECT COUNT(*) n FROM Supplier")),
        ("Models", count("SELECT COUNT(*) n FROM Vehicle_Model")),
        ("In stock", count("SELECT COUNT(*) n FROM Vehicle_Inventory WHERE Status='Available'")),
        ("Sold", count("SELECT COUNT(*) n FROM Vehicle_Inventory WHERE Status='Sold'")),
        ("Customers", count("SELECT COUNT(*) n FROM Customer")),
        ("Orders", count("SELECT COUNT(*) n FROM Sales_Order")),
    ]
    return render_template("home.html", active="home", stats=stats,
                           stock=query("SELECT * FROM Model_Stock ORDER BY Model_Name"))


@app.route("/<key>", methods=["GET", "POST"])
def crud(key):
    if key not in TABLES:
        return redirect(url_for("home"))
    cfg = TABLES[key]
    if request.method == "POST":
        row = {c: (request.form.get(c, "").strip() or None) for c, _, _ in cfg["cols"]}
        new_id = next_id(cfg)
        try:
            names = [cfg["pk"]] + list(row)
            run(f"INSERT INTO {cfg['t']} ({','.join(names)}) VALUES ({','.join(['%s'] * len(names))})",
                [new_id] + list(row.values()))
            if key == "supplier":                       # multivalued attributes
                for e in request.form.get("emails", "").split(","):
                    if e.strip():
                        run("INSERT IGNORE INTO Supplier_Email VALUES (%s,%s)", (new_id, e.strip()))
                for p in request.form.get("phones", "").split(","):
                    if p.strip():
                        run("INSERT IGNORE INTO Supplier_Phone VALUES (%s,%s)", (new_id, p.strip()))
            if key == "order" and row["Status"] in ("Confirmed", "Fulfilled"):
                state = "Sold" if row["Status"] == "Fulfilled" else "Reserved"
                run("UPDATE Vehicle_Inventory SET Status=%s WHERE Inventory_ID=%s", (state, row["Inventory_ID"]))
            db().commit()                               # COMMIT
            flash(f"Record {new_id} added.", "ok")
        except pymysql.MySQLError as e:
            db().rollback()                             # ROLLBACK
            flash(f"Could not add record: {err(e)}", "err")
        return redirect(url_for("crud", key=key))

    fields = []
    for col, label, typ in cfg["cols"]:
        opts = None
        if typ.startswith("fk:"):
            opts, typ = fk_options(typ), "sel"
        elif typ.startswith("sel:"):
            opts, typ = [(o, o) for o in typ[4:].split(",")], "sel"
        fields.append(dict(col=col, label=label, type=typ, opts=opts))
    rows = query(f"SELECT * FROM {cfg['t']} ORDER BY {cfg['pk']}")
    extra = {}
    if key == "supplier":
        for r in rows:
            sid = r["Supplier_ID"]
            extra[sid] = (", ".join(x["Email"] for x in query("SELECT Email FROM Supplier_Email WHERE Supplier_ID=%s", (sid,))),
                          ", ".join(x["Phone_No"] for x in query("SELECT Phone_No FROM Supplier_Phone WHERE Supplier_ID=%s", (sid,))))
    cols = [cfg["pk"]] + [c for c, _, _ in cfg["cols"]]
    return render_template("table.html", active=key, cfg=cfg, key=key, fields=fields,
                           rows=rows, cols=cols, extra=extra)


@app.post("/<key>/delete/<rid>")
def delete(key, rid):
    cfg = TABLES[key]
    try:
        run(f"DELETE FROM {cfg['t']} WHERE {cfg['pk']}=%s", (rid,))
        db().commit()
        flash(f"Record {rid} deleted.", "ok")
    except pymysql.MySQLError as e:
        db().rollback()
        flash(f"Cannot delete {rid}: other records depend on it ({err(e)})", "err")
    return redirect(url_for("crud", key=key))


@app.post("/order/status/<rid>")
def order_status(rid):
    """Changing an order to Fulfilled fires the after_order_fulfilled trigger."""
    status = request.form["status"]
    try:
        run("UPDATE Sales_Order SET Status=%s WHERE Order_ID=%s", (status, rid))
        if status == "Confirmed":
            run("UPDATE Vehicle_Inventory SET Status='Reserved' WHERE Inventory_ID="
                "(SELECT Inventory_ID FROM Sales_Order WHERE Order_ID=%s)", (rid,))
        db().commit()
        flash(f"Order {rid} is now {status}." + (" The trigger marked the vehicle Sold." if status == "Fulfilled" else ""), "ok")
    except pymysql.MySQLError as e:
        db().rollback()
        flash(err(e), "err")
    return redirect(url_for("crud", key="order"))


@app.route("/views")
def views_page():
    names = ["Available_Vehicles", "Order_Summary_View", "Model_Stock"]
    return render_template("views.html", active="views",
                           results=[(n, query(f"SELECT * FROM {n}")) for n in names])


@app.route("/procedures")
def procedures_page():
    status = request.args.get("status", "Pending")
    return render_template("procedures.html", active="procedures", status=status,
                           by_status=call("GetOrdersByStatus", (status,)),
                           available=call("GetAvailableVehicles"),
                           log=query("SELECT * FROM Order_Log ORDER BY Log_ID DESC LIMIT 20"))


# --------------------------------------------------------------------
# Lab queries: read every runnable SELECT / CALL block from docs/lab_record.md
# and execute it live against the database.
# --------------------------------------------------------------------
def runnable(sql):
    stmts = [s.strip() for s in re.sub(r"--.*", "", sql).split(";") if s.strip()]
    return bool(stmts) and all(re.match(r"(?is)(select|call)\b", s) for s in stmts)


def lab_queries():
    out, lab, title, buf, inside = [], "", "", [], False
    for line in LAB_FILE.read_text(encoding="utf8").splitlines():
        if inside:
            if line.startswith("```"):
                inside, sql = False, "\n".join(buf).strip()
                buf = []
                if runnable(sql):
                    out.append((lab, title, sql))
            else:
                buf.append(line)
        elif line.startswith("```sql"):
            inside = True
        elif line.startswith("## LAB"):
            lab, title = line[3:].strip(), ""
        elif (m := re.match(r"\*\*(\d+\..*?)\*\*", line)):
            title = m.group(1)
    return out


@app.route("/lab")
def lab_page():
    groups = {}
    for lab, title, sql in lab_queries():
        try:
            with db().cursor() as cur:
                rows, error = [], None
                for stmt in [s.strip() for s in sql.split(";") if s.strip()]:
                    cur.execute(stmt)
                    rows = list(cur.fetchall())
                    while cur.nextset():
                        pass
        except pymysql.MySQLError as e:
            rows, error = [], err(e)
        groups.setdefault(lab, []).append((title, sql, rows, error))
    return render_template("lab.html", active="lab", groups=groups)


if __name__ == "__main__":
    app.run(debug=True)
