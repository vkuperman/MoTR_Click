<!-- Window is fixed, 102px, pointer cursor, gradual blurry effect on surrounding words. -->
<!--  Comprehension questions appear afterwards in the same slide -->

<template>
  <Experiment title="Mouse tracking for Reading" translate="no">

    <Screen :title="'Welcome'" class="instructions" :validations="{
        SubjectID: {
          minLength: $magpie.v.minLength(2)
        }
      }">
        <!-- <WelcomeScreen /> -->
        <div style="width: 40em; margin: auto;">

        <div style="background-color: lightgrey; padding: 10px;">
            <b> Information About this Study </b>
        </div>
        <p>
          We would like to ask you if you are willing to participate in our research project. Your participation is voluntary. Please read the text below carefully and ask the conducting person about anything you do not understand or would like to know.
        <br><br>
          <b>What is investigated and how?</b> You are being asked to take part in a research study being done by Ethan Wilcox, a researcher at the Swiss Federal Institute of Technology. This study will help us learn about how people read. It will take you around 20 minutes to complete.
        <br><br>
          <b>Who can participate?</b> You can participate only if you are an adult native speaker of English.
        <br><br>
         <b>What am I supposed to do as a participant?</b> If you choose to be in the study, you will use the computer mouse to read sentences in English and answer questions about them.
        <br><br>
          <b>What are my rights during participation?</b> Your participation in this study is voluntary. If you choose to participate, you may change your mind and leave the study at any time by closing the web page without specifying reasons and without any disadvantages.
        <br><br>
          <b>What risks and benefits can I expect?</b> There are no foreseeable risks for participating in this study.
        <br><br>
          <b>Will I be compensated for participating?</b> If you participate you will be compensated for your time following the amount specified on prolific.co.
        <br><br>
          <b>What data is collected from me and how is it used?</b> During this study, we will track the position of your mouse on screen. The data from this study may be presented at scientific conferences and published in scientific journals, as well as in online repositories. All data will remain anonymous. Members of the ETH Zurich Ethics Commission may access the original data for examination purposes. Strict confidentiality will be observed at any time.
        <br><br>
          <b> What are my rights to my personal data? </b> You can request information about the personal data collected from you at any time and without giving reasons. You can also request that it be rectified, handed over to you, barred for processing or erased. To do so, please contact the person indicated below.
        <br><br>
          <b>Who funds this study?</b> This study is funded by an ETH Postdoctoral Fellowship grant, awarded to Ethan Wilcox.
        <br><br>
          <b> How am I insured? </b> Although there are no foreseeable risks for participation, any adverse health effects that are directly caused by a study and can be demonstrated to be attributable to fault on the part of the project team or ETH Zurich are covered by ETH's liability insurance.
        <br><br>
          <b> Who reviewed this study?  </b> This study was examined by the ETH Zurich Ethics Commission as proposal EK 2023-N-03

        <br><br>
          <b> Complaints Office:</b> The secretariat of the ETH Zurich Ethics Committee is available to help you with complaints in connection with your participation. Contact: ethics@sl.ethz.ch or 0041 44 632 85 72.
        <br><br>
          <b> General Contact: </b> Ethan Gotlieb Wilcox, Department of Computer Science, ETH Zurich, OAS K.20, Binzmühlestrasse 13, 8050 Zürich, Switzerland, ethan.wilcox@inf.ethz.ch <br>
        </p>

        <br>
        <div style="background-color: lightgrey; padding: 10px;">
            <b> Consent Form </b>
        </div>
        <br>
        I, the participant, confirm by clicking the button below: <br>
        <div style="padding-left: 30px"> • I have read and understood the study information. My questions have been answered completely and to my satisfaction. </div>
        <div style="padding-left: 30px">• I comply with the inclusion and exclusion criteria for participation described above. I am aware of the requirements and restrictions to be observed during the study. </div>
        <div style="padding-left: 30px">• I have had enough time to decide about my participation. </div>
        <div style="padding-left: 30px">• I participate in this study voluntarily and consent that my personal data be used as described above.</div>
        <div style="padding-left: 30px">• I understand that I can stop participating at any moment.</div>
        <br>

          <tr>
          <td>Please enter your Worker ID to continue:&nbsp</td><td><input name="TurkID" type="text" class="obligatory" v-model="$magpie.measurements.SubjectID"/></td>
          </tr>
          <!-- <tr>
          </tr> -->
          </div>
          <div v-if="
            $magpie.measurements.SubjectID&&
            !$magpie.validateMeasurements.SubjectID.$invalid
            ">
          <br> By clicking on the button below you consent to participating in this study: <br><br>
          <br />
          <button 
            @click="$magpie.addExpData({ SubjectId: $magpie.measurements.SubjectID}); $magpie.nextScreen()">
            Proceed
          </button>

          </div>
        </Screen>


    <InstructionScreen :title="'Instruction'">
<!-- 
      <p>Please use the "Fullscreen Mode" for the duration of the experiment:
        <a href="javascript:void(0)" @click="turnOnFullScreen">Fullscreen Mode</a>
      </p>
 -->
      <p>In this study, you will read short texts and answer questions about them. However, unlike in normal reading, the texts will be blurred. <strong>Click and hold on the text to reveal it;</strong> the reveal stays fixed while you hold. Release to hide. Take as much time to read the text as you need in order to understand it. When you are done reading, answer the question at the bottom and click "next" to move on.</p>
    </InstructionScreen>

    <template v-for="(trial, i) of trials">
      <Screen :key="i" class="main_screen" :progress="i / trials.length">
        <Slide>
          <form>
            <input type="hidden" class="item_id" :value="trial.item_id">
            <input type="hidden" class="experiment_id" :value="trial.experiment_id">
            <input type="hidden" class="condition_id" :value="trial.condition_id">
          </form>
          <div class="oval-cursor"></div>
          <template>
            <div v-if="showFirstDiv" class="readingText" @mousemove="moveCursor" @mousedown="onRevealDown" @mouseup="onRevealUp" @mouseleave="changeBack">
              <template v-for="(word, index) of trial.text.split(' ')">
                <span :key="index" :data-index="index + 1" >
                  {{ word }}
                </span>
              </template>
            </div>
            <div class="blurry-layer" style="opacity: 0.3; filter: blur(3.5px); transition: all 0.3s linear 0s;"> 
              {{trial.text}}
            </div>
          </template>
          <button v-if="showFirstDiv" style= "bottom:40%; transform: translate(-50%, -50%)" @click="toggleDivs" :disabled="!isCursorMoving">
          Done
          </button>

          <div v-else style = "position:absolute; bottom:15%; text-align: center; width: 100%; min-width: -webkit-fill-available;" >
            <template>
              <form>
                <!-- comprehension questions and the response options -->
                <div>{{ trial.question.replace(/ ?["]+/g, '') }}</div>
                <template v-for='(word, index) of trial.response_options'>
                  <input :id="'opt_'+index" type="radio" :value="word" name="opt" v-model="$magpie.measurements.response"/>{{ word }}<br/>
                    <!-- <label :for="'opt_'+index"> {{ word }}&nbsp</label> -->
                </template>
              </form>
            </template>
          </div>
          
          <button v-if="$magpie.measurements.response" style="transform: translate(-50%, -50%)" @click="toggleDivs(); $magpie.saveAndNextScreen()">
            Next
          </button>
        </Slide>
      </Screen>
    </template>
    <SubmitResultsScreen />
  </Experiment>
</template>

<script>
// Load data from csv files as javascript arrays with objects
import localCoherence_list1 from '../trials/localCoherence_list1.tsv';
import localCoherence_list2 from '../trials/localCoherence_list2.tsv';
import localCoherence_list3 from '../trials/localCoherence_list3.tsv';
import localCoherence_practice from '../trials/localCoherence_practice.tsv';

import _ from 'lodash';

export default {
  name: 'App',
  data() {
    const lists = [localCoherence_list1, localCoherence_list2, localCoherence_list3];
    const chosenItems = lists[Math.floor(Math.random() * lists.length)]; // randomly choose one of the lists
    const shuffledItems = _.shuffle(chosenItems); 
    const trials = _.concat(localCoherence_practice, shuffledItems);
    // Create a new column in localCoherences called 'response_options'
    // that concatenates the word in response_true with the two words in response_distractors
    const updatedTrials = trials.map(trial => {
      return {
        ...trial,
        response_options: _.shuffle(`${trial.response_true}|${trial.response_distractors}`.replace(/ ?["]+/g, "").split("|")),
      }
    });
    return {
      isCursorMoving: false,
      isClickHeld: false,
      trials: updatedTrials,
      currentIndex: null,
      showFirstDiv: true,
      mousePosition: {
          x: 0,
          y: 0,
        },
      clickStartTime: null,
      clickStartX: null,
      clickStartY: null,
      clickWordIndex: null,
      clickWord: null,
      clickWordRect: null,
      relativeXInWord: null,
      relativeYInWord: null,
  }},
  computed: {
  },
  mounted() {
    document.addEventListener('mouseup', this.onRevealUp);
  },
  beforeDestroy() {
    document.removeEventListener('mouseup', this.onRevealUp);
  },
  methods: {
    getCharSizePx() {
      const span = this.$el.querySelector('.readingText span[data-index]');
      if (span) {
        const rect = span.getBoundingClientRect();
        const width = span.innerHTML.length > 0 ? rect.width / span.innerHTML.length : 10;
        return { width, height: rect.height };
      }
      return { width: 10, height: 20 };
    },
    getLineClosestTo(clientY) {
      const spans = this.$el.querySelectorAll('.readingText span[data-index]');
      if (!spans.length) return null;
      let best = null;
      let bestDist = Infinity;
      for (let i = 0; i < spans.length; i++) {
        const rect = spans[i].getBoundingClientRect();
        const lineCenter = (rect.top + rect.bottom) / 2;
        const dist = Math.abs(lineCenter - clientY);
        if (dist < bestDist) {
          bestDist = dist;
          best = { lineTop: rect.top, lineBottom: rect.bottom, lineHeight: rect.height };
        }
      }
      return best;
    },
    changeBack() {
      if (this.isClickHeld) {
        this.finishClick(performance.now());
      }
      const oval = this.$el.querySelector(".oval-cursor");
      if (oval) {
        oval.classList.remove('grow');
        oval.classList.remove('blank');
        oval.style.width = '';
        oval.style.height = '';
      }
      this.currentIndex = null;
      this.isClickHeld = false;
    },
    onRevealDown(e) {
      if (this.isClickHeld) return;
      this.isCursorMoving = true;
      this.isClickHeld = true;
      const x = e.clientX;
      const y = e.clientY;
      this.clickStartTime = performance.now();
      this.clickStartX = x;
      this.clickStartY = y;

      const oval = this.$el.querySelector(".oval-cursor");
      const { width: charWidth } = this.getCharSizePx();
      const line = this.getLineClosestTo(y);
      const charsLeft = 4;
      const charsRight = 14;
      const totalChars = charsLeft + charsRight;
      const ovalWidthPx = totalChars * charWidth;
      const ovalHeightPx = line ? line.lineHeight : 20;
      const ovalCenterY = line ? (line.lineTop + line.lineBottom) / 2 : y;
      oval.classList.add('grow');
      oval.style.width = `${ovalWidthPx}px`;
      oval.style.height = `${ovalHeightPx}px`;
      oval.style.left = `${x + (charsRight - charsLeft) / 2 * charWidth}px`;
      oval.style.top = `${ovalCenterY}px`;

      let elementAtCursor = document.elementFromPoint(x, y) && document.elementFromPoint(x, y).closest('span');
      if (!elementAtCursor) {
        elementAtCursor = document.elementFromPoint(x, y - 10) && document.elementFromPoint(x, y - 10).closest('span');
      }
      if (elementAtCursor) {
        oval.classList.remove('blank');
        const rect = elementAtCursor.getBoundingClientRect();
        const relX = rect.width > 0 ? (x - rect.left) / rect.width : null;
        const relY = rect.height > 0 ? (y - rect.top) / rect.height : null;
        this.clickWordIndex = elementAtCursor.getAttribute('data-index');
        this.clickWord = elementAtCursor.innerHTML;
        this.clickWordRect = { top: rect.top, left: rect.left, bottom: rect.bottom, right: rect.right };
        this.relativeXInWord = relX;
        this.relativeYInWord = relY;
        this.currentIndex = this.clickWordIndex;
      } else {
        oval.classList.add('blank');
        this.clickWordIndex = -1;
        this.clickWord = null;
        this.clickWordRect = null;
        this.relativeXInWord = null;
        this.relativeYInWord = null;
        this.currentIndex = -1;
      }
    },
    onRevealUp() {
      if (!this.isClickHeld) return;
      this.finishClick(performance.now());
      const oval = this.$el.querySelector(".oval-cursor");
      if (oval) {
        oval.classList.remove('grow');
        oval.classList.remove('blank');
        oval.style.width = '';
        oval.style.height = '';
      }
      this.isClickHeld = false;
      this.currentIndex = null;
    },
    finishClick(endTime) {
      const expEl = this.$el.querySelector(".experiment_id");
      if (!expEl) return;
      const durationMs = this.clickStartTime != null ? endTime - this.clickStartTime : null;
      const payload = {
        Experiment: expEl.value,
        Condition: this.$el.querySelector(".condition_id").value,
        ItemId: this.$el.querySelector(".item_id").value,
        Index: this.clickWordIndex !== null && this.clickWordIndex !== -1 ? parseInt(this.clickWordIndex, 10) : this.clickWordIndex,
        Word: this.clickWord,
        mousePositionX: this.clickStartX,
        mousePositionY: this.clickStartY,
        clickDurationMs: durationMs,
        relativeXInWord: this.relativeXInWord,
        relativeYInWord: this.relativeYInWord,
      };
      if (this.clickWordRect) {
        payload.wordPositionTop = this.clickWordRect.top;
        payload.wordPositionLeft = this.clickWordRect.left;
        payload.wordPositionBottom = this.clickWordRect.bottom;
        payload.wordPositionRight = this.clickWordRect.right;
      }
      $magpie.addTrialData(payload);
      this.clickStartTime = null;
      this.clickStartX = null;
      this.clickStartY = null;
      this.clickWordIndex = null;
      this.clickWord = null;
      this.clickWordRect = null;
      this.relativeXInWord = null;
      this.relativeYInWord = null;
    },
    moveCursor(e) {
      if (this.isClickHeld) return;
      let x = e.clientX;
      let y = e.clientY;
      const elementAtCursor = document.elementFromPoint(x, y) && document.elementFromPoint(x, y).closest('span');
      if (elementAtCursor) {
        this.currentIndex = elementAtCursor.getAttribute('data-index');
      } else {
        const elementAboveCursor = document.elementFromPoint(x, y - 10) && document.elementFromPoint(x, y - 10).closest('span');
        if (elementAboveCursor) {
          this.currentIndex = elementAboveCursor.getAttribute('data-index');
        } else {
          this.currentIndex = -1;
        }
      }
      this.$el.querySelector(".oval-cursor").style.left = `${x + 12}px`;
      this.$el.querySelector(".oval-cursor").style.top = `${y - 6}px`;
      this.mousePosition.x = e.clientX;
      this.mousePosition.y = e.clientY;
    },
    toggleDivs() {
    this.showFirstDiv = !this.showFirstDiv;
    this.isCursorMoving = false;
    },
    getScreenDimensions() {
      return {
        window_inner_width: window.innerWidth,
        window_inner_height: window.innerHeight
      };
    }
  },
};
</script>


<style>
  .experiment {
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .main_screen {
    isolation: isolate;
    position: relative;
    width: 100%;
    height: auto;
    font-size: 18px;
    line-height: 40px;
  }
  .debugResults{
    width: 100%;
  }
  .readingText {
    /* z-index: 1; */
    position: absolute;
    color: white;
    text-align: left;
    font-weight: 450;
    cursor: pointer;
    padding-top: 2%;
    padding-bottom: 2%;
    padding-left: 8%;
    padding-right: 8%;
  }
  button {
    position: absolute;
    bottom: 0;
    left: 50%;
  }
  .oval-cursor {
    position: fixed;
    /* left: 10px; */
    z-index: 2;
    width: 1px;
    height: 1px;
    transform: translate(-50%, -50%);
    background-color: white;
    mix-blend-mode: difference;
    border-radius: 50%;
    pointer-events: none;
    transition: width 0.5s, height 0.5s;
  } 
  .oval-cursor.grow.blank {
    width: 80px;
    height: 38px;
  }
  .oval-cursor.grow {
    width: 102px;
    height: 38px;
    border-radius: 50%;
    box-shadow: 30px 0 8px -4px rgba(255, 255, 255, 0.1), -30px 0 8px -4px rgba(255, 255, 255, 0.1);
    background-color: rgba(255, 255, 255, 0.3);
    background-blend-mode: screen;
    pointer-events: none;
    transition: width 0.5s, height 0.5s;
    filter:blur(3px);
  }
  .oval-cursor.grow::before {
    content: "";
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 70%;
    height: 70%;
    background-color: white;
    mix-blend-mode: normal;
    border-radius: 50%;
}
  .blurry-layer {
    position: absolute;
    pointer-events: none;
    color: black;
    text-align: left;
    font-weight: 450;
    padding-top: 2%;
    padding-bottom: 2%;
    padding-left: 8%;
    padding-right: 8%;
  }
  * {
    user-select: none; /* Standard syntax */
    -webkit-user-select: none; /* Safari */
    -moz-user-select: none; /* Firefox */
    -ms-user-select: none; /* Internet Explorer/Edge */
    }
</style>
