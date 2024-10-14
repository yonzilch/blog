function setTheme(mode) {
  localStorage.setItem("theme-storage", mode);
  let htmlElement = document.querySelector("html");
  let darkModeStyle = document.getElementById("darkModeStyle");

  if (mode === "dark") {
    if (darkModeStyle) {
      darkModeStyle.disabled = false;
    }
    htmlElement.classList.remove("light");
    htmlElement.classList.add("dark");

    document.getElementById("sun-icon").style.display = "inline-block";
    document.getElementById("moon-icon").style.display = "none";
  } else if (mode === "light") {
    if (darkModeStyle) {
      darkModeStyle.disabled = true;
    }
    htmlElement.classList.remove("dark");
    htmlElement.classList.add("light");

    document.getElementById("sun-icon").style.display = "none";
    document.getElementById("moon-icon").style.display = "inline-block";
  }
}

function toggleTheme() {
  if (localStorage.getItem("theme-storage") === "light") {
    setTheme("dark");
  } else if (localStorage.getItem("theme-storage") === "dark") {
    setTheme("light");
  }
}

function getSavedTheme() {
  let currentTheme = localStorage.getItem("theme-storage");
  if (!currentTheme) {
    if (
      window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: dark)").matches
    ) {
      currentTheme = "dark";
    } else {
      currentTheme = "light";
    }
  }

  return currentTheme;
}

document.addEventListener("DOMContentLoaded", function () {
  setTheme(getSavedTheme());
});
