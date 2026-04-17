import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["userType", "scopeSection", "apartmentSection", "scopeInputs", "apartmentInputs", "buildingSelect", "apartmentGroup"]

  connect() {
    this.toggleSections()
    this.toggleApartmentGroups()
  }

  userTypeChanged() {
    this.toggleSections()
    this.toggleApartmentGroups()
  }

  buildingChanged() {
    this.toggleApartmentGroups()
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

  toggleApartmentGroups() {
    if (!this.hasApartmentSectionTarget) return

    const isResident = this.hasUserTypeTarget && this.userTypeTarget.value === "resident"
    const selectedBuildingId = this.hasBuildingSelectTarget ? this.buildingSelectTarget.value : ""

    if (!isResident) {
      this.apartmentGroupTargets.forEach((group) => group.classList.add("d-none"))
      return
    }

    const shouldShowGroups = selectedBuildingId !== ""

    this.apartmentGroupTargets.forEach((group) => {
      const groupBuildingId = group.dataset.buildingIdValue
      const shouldShow = shouldShowGroups && groupBuildingId === selectedBuildingId
      group.classList.toggle("d-none", !shouldShow)
    })
  }

  checkboxInputs(container) {
    return Array.from(container.querySelectorAll("input[type='checkbox']"))
  }
}