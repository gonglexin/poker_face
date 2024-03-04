// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}

Hooks.Camera = {
  mounted() {
    const startCamera = document.getElementById('startCamera');
    const video = document.getElementById('video');
    const takePhoto = document.getElementById('takePhoto');
    const stopCamera = document.getElementById('stopCamera');
    const canvas = document.getElementById('canvas');
    // const buttonGroup = document.getElementById('buttonGroup');
    this.chats = document.getElementById("chats");
    let stream = null;

    // Start the camera when button is clicked
    startCamera.addEventListener('click', async () => {
      stream = await navigator.mediaDevices.getUserMedia({ video: true });
      video.srcObject = stream;
      // video.classList.remove('hidden');
      // buttonGroup.classList.remove('hidden');
      // startCamera.classList.add('hidden');
    })
    startCamera.click()

    // Take a photo
    takePhoto.addEventListener('click', () => {
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      canvas.getContext('2d').drawImage(video, 0, 0);
      const imageDataURL = canvas.toDataURL('image/png');

      this.pushEvent("new_photo", { photo: imageDataURL })
    })

    this.el.addEventListener("js:ask", () => {
      openai_api_key = document.getElementById("openai").value

      // if (openai_api_key == '') {
      //   alert("Please enter your OpenAI API key.")
      //   abort()
      // }

      question = document.getElementById("question").value

      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      canvas.getContext('2d').drawImage(video, 0, 0);
      const imageDataURL = canvas.toDataURL('image/png');

      this.pushEvent("ask", {
        question: question,
        photo: imageDataURL,
        openai_api_key: openai_api_key
      })
    })

    // Stop the camera
    stopCamera.addEventListener('click', () => {
      if (stream) {
        stream.getTracks().forEach(track => track.stop());
      }
      // buttonGroup.classList.add('hidden');
      // startCamera.classList.remove('hidden');
      video.classList.add('hidden');
      video.srcObject = null;
    })

    this.handleEvent("scroll", () => {
      chats.scrollTop = chats.scrollHeight;
    })
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

