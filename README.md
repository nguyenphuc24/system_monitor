# 🚀 System Monitor Script (CPU / RAM / Disk Alert)

Một script Bash giúp theo dõi tài nguyên hệ thống (CPU, RAM, Disk) và gửi cảnh báo qua Telegram / Email khi vượt ngưỡng.

---

## 📌 Tính năng

* 📊 Theo dõi CPU, RAM, Disk theo thời gian thực
* 🚨 Gửi alert khi vượt threshold
* 🔁 Chạy nền bằng systemd (production-like)
* ⛔ Anti-spam alert (cooldown)
* 📝 Ghi log hệ thống

---

## 🧰 Yêu cầu

* Linux / WSL (Ubuntu khuyến nghị)
* Bash
* `curl`
* `bc`

Cài đặt nếu thiếu:

```bash
sudo apt update
sudo apt install curl bc -y
```

---

## 📥 Cài đặt

### 1. Clone repository

```bash
git clone <repo_url>
cd system-monitor
```

---

### 2. Chạy script setup

```bash
chmod +x run.sh
./run.sh
```

Script sẽ:

* cấp quyền cho `monitor.sh`
* copy file service vào systemd

---

## 🔐 3. Cấu hình `.env`

👉 Bạn cần **tự tạo file `.env`** trong thư mục project:

```bash
nano .env
```

---

### 📌 Nội dung mẫu:

```bash
# Telegram config
BOT_TOKEN=your_bot_token_here
CHAT_ID=your_chat_id_here

# Enable/disable
ENABLE_TELEGRAM=true
ENABLE_EMAIL=false

# Thresholds (%)
CPU_THRESHOLD=80
RAM_THRESHOLD=80
DISK_THRESHOLD=80
```

---

### 🔍 Lưu ý:

* Không có khoảng trắng quanh dấu `=`
* Không commit file `.env` lên GitHub
* BOT_TOKEN và CHAT_ID phải đúng

---

## 🤖 4. Lấy BOT_TOKEN & CHAT_ID

### Bước 1: tạo bot

* vào Telegram → tìm **@BotFather**
* gõ `/start`
* gõ `/newbot`
* lấy `BOT_TOKEN`

---

### Bước 2: lấy CHAT_ID

Gửi 1 tin nhắn cho bot, sau đó chạy:

```bash
curl https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
```

→ tìm `"chat":{"id":...}`

---

## ⚙️ 5. Cấu hình systemd service

Mở file service:

```bash
sudo nano /etc/systemd/system/system-monitor.service
```

---

### 📌 Sửa các dòng sau:

```ini
ExecStart=/full/path/to/system-monitor/monitor.sh
User=your_username
```

---

### 🔥 Ví dụ:

```ini
ExecStart=/home/ubuntu/system-monitor/monitor.sh
User=ubuntu
```

---

## ▶️ 6. Chạy service

```bash
sudo systemctl daemon-reload
sudo systemctl enable system-monitor
sudo systemctl start system-monitor
```

---

## 🔍 7. Kiểm tra

### Trạng thái:

```bash
systemctl status system-monitor
```

---

### Xem log realtime:

```bash
journalctl -u system-monitor -f
```

---

## 🧪 8. Test alert

Giảm threshold trong `.env`:

```bash
CPU_THRESHOLD=1
```

Sau đó restart:

```bash
sudo systemctl restart system-monitor
```

---

## 📁 9. Log

* `logs/monitor.log` → trạng thái hệ thống
* `logs/alert.log` → alert đã gửi

---

## ⛔ Anti-spam

* Không gửi alert liên tục
* Có cooldown (mặc định: 60s)

---

## 🧠 Kiến trúc

* `monitor.sh` → thu thập metrics + logic
* `alert.sh` → gửi alert
* `utils.sh` → anti-spam logic
* systemd → quản lý service

---

## ❗ Lỗi thường gặp

### Không gửi Telegram

* sai BOT_TOKEN / CHAT_ID
* chưa start bot

---

### Service không chạy

```bash
chmod +x monitor.sh
sudo systemctl daemon-reload
```

---

### Không có alert

* chưa vượt threshold
* thiếu `bc`

