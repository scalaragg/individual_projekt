document.addEventListener("DOMContentLoaded", () => {
    Game.init();

    const prevBut = document.getElementById("prevBut");
    const nextBut = document.getElementById("nextBut");

    prevBut.addEventListener("click", () => Game.showPrevImage());
    nextBut.addEventListener("click", () => Game.showNextImage());

    document.addEventListener("keydown", (event) => {
        if (event.key === "ArrowLeft") Game.showPrevImage();
        if (event.key === "ArrowRight") Game.showNextImage();
    });
});