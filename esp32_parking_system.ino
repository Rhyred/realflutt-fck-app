// ===== BLYNK CONFIGURATION (DARI KODE TEMAN ANDA) =====
#define BLYNK_TEMPLATE_ID "TMPL6jkMBKM17"
#define BLYNK_TEMPLATE_NAME "pp"
#define BLYNK_AUTH_TOKEN "qXNGXTXV_Y8HrxFG5lM9CX04RBx-ljyI"

// ===== LIBRARY IMPORT =====
#include <ESP32Servo.h>
#include <SPI.h>
#include <MFRC522.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <WiFi.h>
#include <HTTPClient.h> // Diperlukan untuk Firebase
#include <ArduinoJson.h>
#include <BlynkSimpleEsp32.h>

// ===== WIFI & FIREBASE CONFIGURATION (DARI KODE TEMAN ANDA) =====
const char *ssid = "ICT-LAB WORKSPACE";
const char *password = "ICTLAB2024";
const char *firebaseHost = "my-app-fak-default-rtdb.asia-southeast1.firebasedatabase.app";

// ===== PIN CONFIGURATION (DARI KODE TEMAN ANDA) =====
#define RST_PIN 22
#define SS_PIN 21
#define SERVO_PIN 2
#define TOUCH_PIN 14
#define TOUCH_PIN2 27
#define TOUCH_PIN3 33
#define TOUCH_PIN4 32
#define TRIG_PIN_IN 5
#define ECHO_PIN_IN 17
#define TRIG_PIN_OUT 12
#define ECHO_PIN_OUT 13
#define SDA_LCD 25
#define SCL_LCD 26
#define BTN_PIN 4 // Tombol fisik untuk buka gerbang keluar

// ===== OBJECT DECLARATION (DARI KODE TEMAN ANDA) =====
MFRC522 rfid(SS_PIN, RST_PIN);
Servo myServo;
LiquidCrystal_I2C lcd(0x27, 16, 2);

// ===== VARIABLE (GABUNGAN) =====
bool isOpen = false;
unsigned long openTime = 0;
bool slotTerisi[4] = {false, false, false, false};
String slotIds[4] = {"slot1", "slot2", "slot3", "slot4"}; // Diubah menjadi nama yang konsisten dengan Firebase App
bool entryDetected = false;
unsigned long lastUpdate = 0;
// Variabel baru untuk heartbeat
unsigned long lastHeartbeatTime = 0;
const long heartbeatInterval = 60000; // Interval detak jantung: 60 detik

// ===== SETUP =====
void setup()
{
  Serial.begin(115200);
  SPI.begin();
  rfid.PCD_Init();
  Wire.begin(SDA_LCD, SCL_LCD);
  lcd.init();
  lcd.backlight();

  lcd.setCursor(0, 0);
  lcd.print("Sistem Parkir");
  lcd.setCursor(0, 1);
  lcd.print("Smart Dimulai");
  delay(2000);
  lcd.clear();

  myServo.attach(SERVO_PIN);
  myServo.write(0);

  pinMode(TOUCH_PIN, INPUT);
  pinMode(TOUCH_PIN2, INPUT);
  pinMode(TOUCH_PIN3, INPUT);
  pinMode(TOUCH_PIN4, INPUT);
  pinMode(TRIG_PIN_IN, OUTPUT);
  pinMode(ECHO_PIN_IN, INPUT);
  pinMode(TRIG_PIN_OUT, OUTPUT);
  pinMode(ECHO_PIN_OUT, INPUT);
  pinMode(BTN_PIN, INPUT_PULLUP);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  lcd.print("WiFi Connecting");

  unsigned long startTime = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - startTime < 10000)
  {
    delay(500);
    Serial.print(".");
  }

  lcd.clear();
  if (WiFi.status() == WL_CONNECTED)
  {
    lcd.print("WiFi Connected");
    Serial.println("\nWiFi Connected");
  }
  else
  {
    lcd.print("WiFi Failed");
    Serial.println("\nWiFi Failed");
  }

  Blynk.config(BLYNK_AUTH_TOKEN);
  Blynk.connect();
}

// ===== LOOP =====
void loop()
{
  if (WiFi.status() == WL_CONNECTED)
    Blynk.run();

  bacaSlot();
  cekUltrasonicIn();
  cekUltrasonicOut();
  cekTombolFisik();
  tutupGerbangOtomatis();

  if (millis() - lastUpdate > 2000)
  {
    updateLCD();
    lastUpdate = millis();
  }

  // ===== TAMBAHAN: KIRIM HEARTBEAT KE FIREBASE =====
  if (millis() - lastHeartbeatTime > heartbeatInterval)
  {
    lastHeartbeatTime = millis();
    kirimHeartbeat();
  }
}

// ===== FUNGSI BARU UNTUK FIREBASE =====
void updateFirebaseSlot(String slotId, bool status)
{
  if (WiFi.status() == WL_CONNECTED)
  {
    HTTPClient http;
    String url = "https://" + String(firebaseHost) + "/parking_slots/" + slotId + ".json";
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    http.PUT(status ? "true" : "false");
    http.end();
  }
}

void kirimHeartbeat()
{
  if (WiFi.status() == WL_CONNECTED)
  {
    HTTPClient http;
    String url = "https://" + String(firebaseHost) + "/system_status/esp32_last_seen.json";
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    http.PUT("{\".sv\": \"timestamp\"}");
    http.end();
  }
}

// ===== BACA SLOT (DENGAN TAMBAHAN FIREBASE) =====
void bacaSlot()
{
  slotTerisi[0] = digitalRead(TOUCH_PIN);
  slotTerisi[1] = digitalRead(TOUCH_PIN2);
  slotTerisi[2] = digitalRead(TOUCH_PIN3);
  slotTerisi[3] = digitalRead(TOUCH_PIN4);

  for (int i = 0; i < 4; i++)
  {
    Blynk.virtualWrite(V0 + i, slotTerisi[i] ? 1 : 0);
    updateFirebaseSlot(slotIds[i], slotTerisi[i]); // <-- KIRIM DATA KE FIREBASE
  }
}

// ===== SISA FUNGSI DARI KODE TEMAN ANDA (TIDAK DIUBAH) =====
void updateLCD()
{
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.printf("S1:%s S2:%s", slotTerisi[0] ? "T" : "K", slotTerisi[1] ? "T" : "K");
  lcd.setCursor(0, 1);
  lcd.printf("S3:%s S4:%s", slotTerisi[2] ? "T" : "K", slotTerisi[3] ? "T" : "K");
}

void cekUltrasonicIn()
{
  float jarak = bacaJarak(TRIG_PIN_IN, ECHO_PIN_IN);
  entryDetected = (jarak >= 6.0 && jarak <= 9.0);
}

void cekUltrasonicOut()
{
  float jarak = bacaJarak(TRIG_PIN_OUT, ECHO_PIN_OUT);
  if (jarak >= 2.0 && jarak <= 4.5 && !isOpen)
    bukaGerbang("autoOut");
}

void cekTombolFisik()
{
  if (digitalRead(BTN_PIN) == LOW && entryDetected && !isOpen)
  {
    bukaGerbang("btnFisik");
    delay(300); // debounce sederhana
  }
}

BLYNK_WRITE(V4)
{
  if (param.asInt() == 1 && entryDetected && !isOpen)
  {
    bukaGerbang("blynk");
  }
}

void bukaGerbang(String source)
{
  myServo.write(90);
  isOpen = true;
  openTime = millis();

  lcd.clear();
  lcd.print("Gerbang Dibuka");

  Blynk.virtualWrite(V5, source + " buka");
}

void tutupGerbangOtomatis()
{
  if (isOpen && millis() - openTime > 7000)
  {
    myServo.write(0);
    isOpen = false;

    lcd.clear();
    lcd.print("Gerbang Tertutup");

    Blynk.virtualWrite(V5, "Gerbang Tertutup");
  }
}

float bacaJarak(int trig, int echo)
{
  digitalWrite(trig, LOW);
  delayMicroseconds(2);
  digitalWrite(trig, HIGH);
  delayMicroseconds(10);
  digitalWrite(trig, LOW);
  long dur = pulseIn(echo, HIGH, 30000);
  return dur * 0.034 / 2;
}
