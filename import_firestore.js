const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

const serviceAccount = JSON.parse(
    fs.readFileSync("./my-app-fak-firebase.json", "utf8")
);

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const data = JSON.parse(fs.readFileSync("./firestore_data.json", "utf8"));

// Fungsi rekursif untuk mengganti __datatype__: "Timestamp"
function convertDataTypes(obj) {
    if (Array.isArray(obj)) {
        return obj.map(convertDataTypes);
    } else if (obj !== null && typeof obj === "object") {
        if (
            obj.__datatype__ === "Timestamp" &&
            typeof obj.value === "string"
        ) {
            return admin.firestore.Timestamp.fromDate(new Date(obj.value));
        }

        const newObj = {};
        for (const key in obj) {
            newObj[key] = convertDataTypes(obj[key]);
        }
        return newObj;
    } else {
        return obj;
    }
}

async function importCollection(collectionName, documents) {
    const batch = db.batch();
    for (const [docId, docData] of Object.entries(documents)) {
        const ref = db.collection(collectionName).doc(docId);
        batch.set(ref, convertDataTypes(docData));
    }
    await batch.commit();
    console.log(`✅ Imported ${collectionName}`);
}

// Jalankan import untuk setiap koleksi
(async () => {
    for (const [collection, documents] of Object.entries(data)) {
        await importCollection(collection, documents);
    }
    console.log("✅ All data imported successfully.");
})();
