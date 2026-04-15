import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["userType", "scopeSection", "apartmentSection", "scopeInputs", "apartmentInputs"]

  connect() {
    this.toggleSections()
  }

  userTypeChanged() {
    this.toggleSections()
  }

  toggleSections() {
    if (!this.hasUserTypeTarget) return

    const userType = this.userTypeTarget.value
    const isResident = userType === "resident"
    const isCollaborator = userType === "colaborator"

    this.toggleSection(this.scopeSectionTarget, this.scopeInputsTarget, isCollaborator)
    this.toggleSection(this.apartmentSectionTarget, this.apartmentInputsTarget, isResident)
  }

  toggleSection(sectionTarget, inputsContainerTarget, shouldShow) {
    if (!sectionTarget || !inputsContainerTarget) return

    sectionTarget.classList.toggle("d-none", !shouldShow)

    const inputs = this.checkboxInputs(inputsContainerTarget)
    inputs.forEach((input) => {
      input.disabled = !shouldShow
    })

    if (!shouldShow) {
      inputs.forEach((input) => {
        input.checked = false
      })
    }
  }

  checkboxInputs(container) {
    return Array.from(container.querySelectorAll("input[type='checkbox']"))
  }
}