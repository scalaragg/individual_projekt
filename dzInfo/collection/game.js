const Game = {
    canvas: null,
    ctx: null,
    currentImage: null,
    images: [],
    currentIndex: 0,

    init() {
        console.log("Game.init() вызван");

        this.canvas = document.getElementById("gameCanvas");
        if (!this.canvas) {
            console.error("Canvas не найден!");
            return;
        }

        this.ctx = this.canvas.getContext("2d");

        if (typeof CONFIG !== "undefined" && Array.isArray(CONFIG.images)) {
            this.images = CONFIG.images;
        }

        this.currentIndex = 0;
        this.loadCurrentImage();
    },

    loadCurrentImage() {
        if (!this.images.length) return;

        this.currentImage = new Image();
        this.currentImage.src = this.images[this.currentIndex];

        this.currentImage.onload = () => {
            this.drawImage();
            this.updateCounter();
        };

        this.currentImage.onerror = () => {
            console.error("Ошибка загрузки изображения");
        };
    },

    drawImage() {
        if (!this.currentImage || !this.ctx) return;

        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        const img = this.currentImage;
        const cw = this.canvas.width;
        const ch = this.canvas.height;
        const ratio = img.width / img.height;

        let dw, dh, dx, dy;

        if (ratio > cw / ch) {
            dw = cw;
            dh = dw / ratio;
            dx = 0;
            dy = (ch - dh) / 2;
        } else {
            dh = ch;
            dw = dh * ratio;
            dx = (cw - dw) / 2;
            dy = 0;
        }

        this.ctx.drawImage(img, dx, dy, dw, dh);
    },

    updateCounter() {
        const counter = document.getElementById("count");
        if (counter) counter.textContent = `${this.currentIndex + 1} / ${this.images.length}`;
    },

    showPrevImage() {
        if (!this.images.length) return;
        this.currentIndex = (this.currentIndex - 1 + this.images.length) % this.images.length;
        this.loadCurrentImage();
    },

    showNextImage() {
        if (!this.images.length) return;
        this.currentIndex = (this.currentIndex + 1) % this.images.length;
        this.loadCurrentImage();
    }
};