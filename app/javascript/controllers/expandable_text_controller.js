import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "full", "toggle"]

  connect() {
    this.expanded = false
  }

  toggle(event) {
    event.preventDefault()
    this.expanded = !this.expanded
    this.render()
  }

  render() {
    if (!this.hasPreviewTarget || !this.hasFullTarget) return

    this.previewTarget.classList.toggle("d-none", this.expanded)
    this.fullTarget.classList.toggle("d-none", !this.expanded)

    if (!this.hasToggleTarget) return

    this.toggleTarget.textContent = this.expanded ? "Ver menos" : "Ver mais"
    this.toggleTarget.setAttribute("aria-expanded", this.expanded.toString())
  }
}
