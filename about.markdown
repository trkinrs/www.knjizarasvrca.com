---
layout: page
title: O nama
permalink: /about/
---
<style>
td button {
    display: none; /* Hide button initially */
}

td:hover button {
    display: inline-block; /* Show button when hovering over the cell */
}
</style>
  <script type="module">
	import { Application, Controller } from "https://esm.sh/@hotwired/stimulus"
    window.Stimulus = Application.start()

    Stimulus.register("hello", class extends Controller {
      static targets = [ "name" ]

      connect() {
      console.log("connected")
      this.nameTarget.value ="hello"
      }
    })
  </script>
  <script type="module">
	import { Application, Controller } from "https://esm.sh/@hotwired/stimulus"
    Stimulus.register("clipboard", class extends Controller {
      static targets = ["button", "source"]
      static values = {
        successContent: String,
        successDuration: {
          type: Number,
          default: 2000
        }
      }

      connect() {
        console.log("clipboard connect")
        if (!this.hasButtonTarget) return

        this.originalContent = this.buttonTarget.innerHTML
      }

      copy(event) {
        event.preventDefault()

        const text = this.sourceTarget.innerHTML || this.sourceTarget.value

        navigator.clipboard.writeText(text).then(() => this.copied())
      }

      copied() {
        if (!this.hasButtonTarget) return

        if (this.timeout) {
          clearTimeout(this.timeout)
        }

        this.buttonTarget.innerHTML = this.successContentValue

        this.timeout = setTimeout(() => {
          this.buttonTarget.innerHTML = this.originalContent
        }, this.successDurationValue)
      }
    })
  </script>
<table>
  <tbody>
    <tr>
      <td>Poslovno ime (name):</td>
      <td data-controller="clipboard" data-clipboard-success-content-value="Copied!">
        <span data-clipboard-target="source">ŠVRĆA DRUŠTVO SA OGRANIČENOM ODGOVORNOŠĆU ZA PROMET ROBA SRBOBRAN</span>
        <button type="button" data-action="clipboard#copy" data-clipboard-target="button">Copy</button>
      </td>
    </tr>
    <tr>
      <td>Skraćeno poslovno ime (short name):</td>
      <td data-controller="clipboard" data-clipboard-success-content-value="Copied!">
        <span data-clipboard-target="source">Švrća</span>
        <button type="button" data-action="clipboard#copy" data-clipboard-target="button">Copy</button>
      </td>
    </tr>
    <tr>
      <td>Matični broj (corporate ID):</td>
      <td data-controller="clipboard" data-clipboard-success-content-value="Copied!">
        <span data-clipboard-target="source">08283028</span>
        <button type="button" data-action="clipboard#copy" data-clipboard-target="button">Copy</button>
      </td>
    </tr>
    <tr>
      <td>PIB (tax ID):</td>
      <td data-controller="clipboard" data-clipboard-success-content-value="Copied!">
        <span data-clipboard-target="source">101425778</span>
        <button type="button" data-action="clipboard#copy" data-clipboard-target="button">Copy</button>
      </td>
    </tr>
    <tr>
      <td>Račun u banci (bank account):</td>
      <td data-controller="clipboard" data-clipboard-success-content-value="Copied!">
        <span data-clipboard-target="source">265-2050310003018-19</span>
        <button type="button" data-action="clipboard#copy" data-clipboard-target="button">Copy</button>
      </td>
    </tr>
    <tr>
      <td>Poslovno sedište (address):</td>
      <td data-controller="clipboard" data-clipboard-success-content-value="Copied!">
        <span data-clipboard-target="source">Trg Republike 1</span>
        <button type="button" data-action="clipboard#copy" data-clipboard-target="button">Copy</button>
      </td>
    </tr>
    <tr>
      <td>Poštanski broj, grad i drzava (zip, city, country):</td>
      <td data-controller="clipboard" data-clipboard-success-content-value="Copied!">
        <span data-clipboard-target="source">21480 Srbobran</span>
        <button type="button" data-action="clipboard#copy" data-clipboard-target="button">Copy</button>
      </td>
    </tr>
    <tr>
      <td>Imejl (email):</td>
      <td data-controller="clipboard" data-clipboard-success-content-value="Copied!">
        <span data-clipboard-target="source">knjizarasvrca@gmail.com</span>
        <button type="button" data-action="clipboard#copy" data-clipboard-target="button">Copy</button>
      </td>
    </tr>
    <tr>
      <td>Telefon (mobile):</td>
      <td data-controller="clipboard" data-clipboard-success-content-value="Copied!">
        <span data-clipboard-target="source">021/730-093</span>
        <button type="button" data-action="clipboard#copy" data-clipboard-target="button">Copy</button>
      </td>
    </tr>
  </tbody>
</table>
