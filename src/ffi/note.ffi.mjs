// arata — note toggle FFI: attaches click handlers to `.note-toggle` buttons
// so dynamic notes can expand/collapse, mirroring apollo's `static/js/note.js`.
//
// For each `.note-toggle` button, toggles the `display` style of the next
// `.note-content` sibling between "none" and "block", and flips the
// `aria-expanded` attribute on the button.

export function enhance_notes() {
  const toggles = document.querySelectorAll(".note-toggle");
  toggles.forEach((button) => {
    if (button.getAttribute("data-arata-enhanced")) return; // skip if already done
    button.setAttribute("data-arata-enhanced", "true");
    button.setAttribute("aria-expanded", "false");

    button.addEventListener("click", () => {
      const content = button.nextElementSibling;
      if (!content || !content.classList.contains("note-content")) return;
      const isHidden = content.style.display === "none";
      content.style.display = isHidden ? "block" : "none";
      button.setAttribute("aria-expanded", isHidden ? "true" : "false");
    });
  });
}
