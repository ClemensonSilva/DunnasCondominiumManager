import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  static values = {
    autoOpen: Boolean,
    modalId: String
  }

  connect() {
    if (this.autoOpenValue) {
      this.open()
    }
  }

  open(event) {
    if (event) event.preventDefault()

    const modalElement = this.findModalElement(event)
    if (!modalElement || !window.bootstrap) return

    window.bootstrap.Modal.getOrCreateInstance(modalElement).show()
  }

  close(event) {
    if (event) event.preventDefault()

    const modalElement = this.findModalElement(event)
    if (!modalElement || !window.bootstrap) return

    window.bootstrap.Modal.getOrCreateInstance(modalElement).hide()
  }

  findModalElement(event) {
    if (this.hasModalTarget) return this.modalTarget

    const modalIdFromEvent = event?.params?.id
    if (modalIdFromEvent) return document.getElementById(modalIdFromEvent)

    if (this.hasModalIdValue) return document.getElementById(this.modalIdValue)

    return this.element.classList.contains("modal") ? this.element : null
  }
}