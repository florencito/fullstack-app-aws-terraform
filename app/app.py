from flask import Flask, jsonify, request

app = Flask(__name__)

# Mock de inventario
inventory = [
    {"id": 1, "name": "Producto A"},
    {"id": 2, "name": "Producto B"}
]

@app.route("/")
def home():
    return "Hola desde Flask en EC2 Docker!"

@app.route("/inventario", methods=["GET", "POST", "PUT", "DELETE"])
def inventario():
    if request.method == "GET":
        return jsonify(inventory)
    elif request.method == "POST":
        data = request.json
        inventory.append(data)
        return jsonify({"message": "Producto agregado"}), 201
    elif request.method == "PUT":
        data = request.json
        for item in inventory:
            if item["id"] == data["id"]:
                item.update(data)
                return jsonify({"message": "Producto actualizado"}), 200
        return jsonify({"error": "Producto no encontrado"}), 404
    elif request.method == "DELETE":
        data = request.json
        for i, item in enumerate(inventory):
            if item["id"] == data["id"]:
                del inventory[i]
                return jsonify({"message": "Producto eliminado"}), 200
        return jsonify({"error": "Producto no encontrado"}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
