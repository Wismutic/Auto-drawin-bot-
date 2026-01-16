> Wismuti:
import tkinter as tk
from tkinter import filedialog, messagebox
from PIL import Image
import numpy as np
import pyautogui
import threading
import time
import webbrowser  # для открытия ссылок

pyautogui.FAILSAFE = True

zone = None
image_path = None
running = False

# --- Функции выбора зоны и загрузки картинки ---
def select_zone():
    global zone
    messagebox.showinfo(
        "Выбор зоны",
        "Наведи мышь в ЛЕВЫЙ ВЕРХНИЙ угол зоны и нажми Enter в консоли"
    )
    input("Левый верхний угол -> Enter")
    x1, y1 = pyautogui.position()

    input("Правый нижний угол -> Enter")
    x2, y2 = pyautogui.position()

    zone = (x1, y1, x2, y2)
    zone_label.config(text=f"Зона: {x2 - x1} x {y2 - y1}")


def load_image():
    global image_path
    image_path = filedialog.askopenfilename(
        filetypes=[("Images", "*.png *.jpg *.jpeg")]
    )
    if image_path:
        image_label.config(text=image_path.split("/")[-1])


# --- Функции рисования ---
def draw_points(pixels, x1, y1, width, height, threshold, step):
    for y in range(0, height, step):
        if not running:
            break
        for x in range(0, width, step):
            if pixels[y, x] < threshold:
                pyautogui.click(x1 + x, y1 + y)


def draw_lines(pixels, x1, y1, width, height, threshold):
    for y in range(height):
        if not running:
            break
        drawing = False
        for x in range(width):
            if pixels[y, x] < threshold:
                if not drawing:
                    pyautogui.mouseDown(x1 + x, y1 + y)
                    drawing = True
                else:
                    pyautogui.moveTo(x1 + x, y1 + y)
            else:
                if drawing:
                    pyautogui.mouseUp()
                    drawing = False
        if drawing:
            pyautogui.mouseUp()


def draw():
    global running
    if not zone or not image_path:
        messagebox.showerror("Ошибка", "Выбери зону и картинку")
        return

    running = True

    x1, y1, x2, y2 = zone
    width = x2 - x1
    height = y2 - y1

    img = Image.open(image_path).convert("L")
    img = img.resize((width, height))
    pixels = np.array(img)

    threshold = threshold_scale.get()
    step = step_scale.get()
    mode = draw_mode.get()

    time.sleep(2)  # время переключиться в редактор

    if mode == "points":
        draw_points(pixels, x1, y1, width, height, threshold, step)
    else:
        draw_lines(pixels, x1, y1, width, height, threshold)

    running = False


def start():
    threading.Thread(target=draw).start()


def stop():
    global running
    running = False

# --- Функции для рекламы / ссылок ---
def open_discord():
    webbrowser.open("https://discord.gg/yfYdZjYd")

def open_telegram():
    webbrowser.open("https://t.me/wismutic")  # открывает Telegram через веб


# --- GUI ---
root = tk.Tk()
root.title("Помощник рисования")
root.geometry("450x500")

# Зона
tk.Button(root, text="Выбрать зону", command=select_zone).pack(pady=5)
zone_label = tk.Label(root, text="Зона: не выбрана")
zone_label.pack()

# Картинка
tk.Button(root, text="Загрузить картинку", command=load_image).pack(pady=5)
image_label = tk.Label(root, text="Картинка: не выбрана")
image_label.pack()

# Режим рисования
tk.Label(root, text="Режим рисования").pack(pady=5)
draw_mode = tk.StringVar(value="points")
tk.Radiobutton(root, text="Точками", variable=draw_mode, value="points").pack()
tk.Radiobutton(root, text="Линиями", variable=draw_mode, value="lines").pack()

# Настройки
tk.Label(root, text="Чувствительность (темнота)").pack()
threshold_scale = tk.Scale(root, from_=0, to=255, orient="horizontal")
threshold_scale.set(120)
threshold_scale.pack()

tk.Label(root, text="Шаг (только для точек)").pack()
step_scale = tk.Scale(root, from_=1, to=5, orient="horizontal")
step_scale.set(2)
step_scale.pack()

# Старт/Стоп
tk.Button(root, text="СТАРТ", bg="green", fg="white", command=start).pack(pady=10)
tk.Button(root, text="СТОП", bg="red", fg="white", command=stop).pack()

> Wismuti:
# Экстренная остановка
tk.Label(root, text="Экстренная остановка — увести мышь в угол").pack(pady=10)

# --- Реклама / ссылки ---
tk.Label(root, text="Связаться со мной:", font=("Arial", 10, "bold")).pack(pady=5)

tk.Button(root, text="Discord канал", fg="white", bg="#7289DA", width=20, command=open_discord).pack(pady=3)
tk.Button(root, text="Telegram @wismutic", fg="white", bg="#0088CC", width=20, command=open_telegram).pack(pady=3)

root.mainloop()
