from flask import Flask, request, jsonify, render_template
import mysql.connector
import os

app = Flask(__name__)

# Conexión a MySQL usando .env
db_config = {
    'host': os.environ.get('DB_HOST', 'webapp-project-mysql.cst866sqsagj.us-east-1.rds.amazonaws.com'),
    'port': int(os.environ.get('DB_PORT', 3306)),
    'user': os.environ.get('DB_USER', 'admin'),
    'password': os.environ.get('DB_PASSWORD', 'Admin12345!'),
    'database': os.environ.get('DB_NAME', 'inventario_db')
}

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/inventario", methods=["GET", "POST", "PUT", "DELETE"])
def inventario():
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)

    if request.method == "GET":
        cursor.execute("SELECT * FROM productos")
        results = cursor.fetchall()
        conn.close()
        return jsonify(results)

    elif request.method == "POST":
        data = request.json
        cursor.execute("INSERT INTO productos (nombre, cantidad) VALUES (%s, %s)",
                       (data["nombre"], data["cantidad"]))
        conn.commit()
        conn.close()
        return jsonify({"message": "Producto agregado"}), 201

    elif request.method == "PUT":
        data = request.json
        cursor.execute("UPDATE productos SET nombre=%s, cantidad=%s WHERE id=%s",
                       (data["nombre"], data["cantidad"], data["id"]))
        conn.commit()
        conn.close()
        return jsonify({"message": "Producto actualizado"}), 200

    elif request.method == "DELETE":
        data = request.json
        cursor.execute("DELETE FROM productos WHERE id=%s", (data["id"],))
        conn.commit()
        conn.close()
        return jsonify({"message": "Producto eliminado"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
