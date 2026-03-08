<!-- Window is fixed, 102px, pointer cursor, gradual blurry effect on surrounding words. -->
<!--  Comprehension questions appear afterwards in the same slide -->

<template>
  <Experiment title="Mouse tracking for Reading" translate="no">
    <InstructionScreen :title="'Instruction'">
      <p>In this study, you will read short texts and answer questions about them. However, unlike in normal reading, the texts will be blurred. <strong>Click and hold on the text to reveal it;</strong> the reveal stays fixed while you hold. Release to hide. Take as much time to read the text as you need. When you are done reading, answer all comprehension questions and click "Next" to continue.</p>
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
          <div v-show="showFakeCursor" class="fake-cursor" :style="{ left: fakeCursorX + 'px', top: fakeCursorY + 'px' }"></div>
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
          <button v-if="showFirstDiv" style= "bottom:40%; transform: translate(-50%, -50%)" @click="toggleDivs(trial)" :disabled="!isCursorMoving">
          Done
          </button>

          <div v-else v-show="trial.questions.length" style = "position:absolute; bottom:15%; text-align: center; width: 100%; min-width: -webkit-fill-available;" >
            <template>
              <form>
                <template v-for="(q, qIdx) of trial.questions">
                  <div :key="qIdx" class="comprehension-question">
                    <div class="question-text">{{ q.question }}</div>
                    <template v-if="q.type === 'yes_no'">
                      <label><input type="radio" :name="'q_'+i+'_'+qIdx" value="Yes" v-model="$magpie.measurements.responses[qIdx]"/> Yes</label>
                      <label><input type="radio" :name="'q_'+i+'_'+qIdx" value="No" v-model="$magpie.measurements.responses[qIdx]"/> No</label>
                    </template>
                    <template v-else>
                      <template v-for="(opt, oIdx) of (q.options || [])">
                        <label :key="oIdx"><input type="radio" :name="'q_'+i+'_'+qIdx" :value="opt" v-model="$magpie.measurements.responses[qIdx]"/> {{ opt }}</label><br/>
                      </template>
                    </template>
                  </div>
                </template>
              </form>
            </template>
          </div>
          
          <button v-if="allResponsesFilled(trial)" style="transform: translate(-50%, -50%)" @click="toggleDivs(); $magpie.saveAndNextScreen()">
            Next
          </button>
        </Slide>
      </Screen>
    </template>
    <ExportReportsScreen />
    <SubmitResultsScreen />
  </Experiment>
</template>

<script>
// Load data from csv files as javascript arrays with objects
import provo_list1 from '../trials/provo_items_list1.tsv';
import provo_practice from '../trials/provo_items_practice.tsv';
import _ from 'lodash';
import ExportReportsScreen from './components/ExportReportsScreen.vue';

export default {
  name: 'App',
  components: { ExportReportsScreen },
  data() {
    const chosenItems = provo_list1; 
    const shuffledItems = _.shuffle(chosenItems); 
    const trials = _.concat(provo_practice, shuffledItems);
    // Normalize trials: ensure each has a .questions array (yes_no or multiple_choice).
    // If trial.questions is a JSON string, parse it. Else build one question from question/response_true/response_distractors.
    const updatedTrials = trials.map(trial => {
      let questions = [];
      if (trial.questions != null && trial.questions !== '') {
        try {
          questions = typeof trial.questions === 'string' ? JSON.parse(trial.questions) : trial.questions;
        } catch (_) {
          questions = [];
        }
      }
      if (!questions.length && trial.question) {
        const opts = _.shuffle(`${trial.response_true || ''}|${trial.response_distractors || ''}`.replace(/ ?["]+/g, '').split('|').filter(Boolean));
        questions = [{ type: 'multiple_choice', question: trial.question.replace(/ ?["]+/g, ''), correct: trial.response_true, options: opts }];
      }
      return {
        ...trial,
        questions,
        response_options: trial.response_true != null ? _.shuffle(`${trial.response_true}|${trial.response_distractors}`.replace(/ ?["]+/g, '').split('|')) : [],
      };
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
      clickLineNumber: null,
      clickPositionInLine: null,
      showFakeCursor: false,
      fakeCursorX: 0,
      fakeCursorY: 0,
      mouseMovedMoreThan5Px: false,
  }},
  computed: {
  },
  mounted() {
    document.addEventListener('mouseup', this.onRevealUp);
    document.addEventListener('mousemove', this.trackMovementDuringHold);
  },
  beforeDestroy() {
    document.removeEventListener('mouseup', this.onRevealUp);
    document.removeEventListener('mousemove', this.trackMovementDuringHold);
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
    pointToRectDistance(px, py, rect) {
      const dx = Math.max(0, rect.left - px, px - rect.right);
      const dy = Math.max(0, rect.top - py, py - rect.bottom);
      return Math.sqrt(dx * dx + dy * dy);
    },
    getClosestWordWithin10px(clientX, clientY) {
      const spans = this.$el.querySelectorAll('.readingText span[data-index]');
      if (!spans.length) return null;
      const ABOVE_BONUS_PX = 5;
      let best = null;
      let bestEffectiveDist = Infinity;
      for (let i = 0; i < spans.length; i++) {
        const rect = spans[i].getBoundingClientRect();
        const dist = this.pointToRectDistance(clientX, clientY, rect);
        const wordCenterY = (rect.top + rect.bottom) / 2;
        const isAbove = wordCenterY < clientY;
        const effectiveDist = dist + (isAbove ? -ABOVE_BONUS_PX : ABOVE_BONUS_PX);
        if (effectiveDist < bestEffectiveDist) {
          bestEffectiveDist = effectiveDist;
          best = { element: spans[i], rect, dist };
        }
      }
      if (!best || best.dist > 10) return null;
      const rect = best.rect;
      return {
        element: best.element,
        index: best.element.getAttribute('data-index'),
        word: best.element.innerHTML,
        rect: { top: rect.top, left: rect.left, bottom: rect.bottom, right: rect.right }
      };
    },
    getWordLineAndPositionInLine(wordIndex) {
      const spans = this.$el.querySelectorAll('.readingText span[data-index]');
      if (!spans.length) return { lineNumber: null, positionInLine: null };
      const items = [];
      for (let i = 0; i < spans.length; i++) {
        const rect = spans[i].getBoundingClientRect();
        const idx = spans[i].getAttribute('data-index');
        items.push({ index: idx, top: rect.top, left: rect.left });
      }
      const tol = 3;
      const byLine = {};
      for (const it of items) {
        const key = Math.round(it.top / tol) * tol;
        if (!byLine[key]) byLine[key] = [];
        byLine[key].push(it);
      }
      const lines = Object.keys(byLine).map(k => byLine[k]).sort((a, b) => a[0].top - b[0].top);
      for (let l = 0; l < lines.length; l++) {
        lines[l].sort((a, b) => a.left - b.left);
        for (let p = 0; p < lines[l].length; p++) {
          if (String(lines[l][p].index) === String(wordIndex)) {
            return { lineNumber: l + 1, positionInLine: p + 1 };
          }
        }
      }
      return { lineNumber: null, positionInLine: null };
    },
    changeBack() {
      if (this.isClickHeld) {
        this.fakeCursorX = this.clickStartX;
        this.fakeCursorY = this.clickStartY;
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
      if (this.showFakeCursor) {
        this.showFakeCursor = false;
        document.body.style.cursor = '';
      }
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
      this.showFakeCursor = true;
      this.fakeCursorX = x;
      this.fakeCursorY = y;
      this.mouseMovedMoreThan5Px = false;
      document.body.style.cursor = 'none';

      const oval = this.$el.querySelector(".oval-cursor");
      const { width: charWidth, height: charHeight } = this.getCharSizePx();
      const line = this.getLineClosestTo(y);
      const ch = charHeight || 20;
      const refY = line ? line.lineBottom + 3 : y;
      const charsLeft = 4;
      const charsRight = 14;
      const totalChars = charsLeft + charsRight;
      const ovalWidthPx = totalChars * charWidth;
      const ovalHeightPx = (1.5 + 0.3) * ch;
      const ovalCenterY = refY - (1.5 - 0.3) / 2 * ch;
      oval.classList.add('grow');
      oval.style.width = `${ovalWidthPx}px`;
      oval.style.height = `${ovalHeightPx}px`;
      oval.style.left = `${x + (charsRight - charsLeft) / 2 * charWidth}px`;
      oval.style.top = `${ovalCenterY}px`;

      const closest = this.getClosestWordWithin10px(x, y);
      if (closest) {
        oval.classList.remove('blank');
        const rect = closest.rect;
        const relX = rect.right > rect.left ? (x - rect.left) / (rect.right - rect.left) : null;
        const relY = rect.bottom > rect.top ? (y - rect.top) / (rect.bottom - rect.top) : null;
        this.clickWordIndex = closest.index;
        this.clickWord = closest.word;
        this.clickWordRect = rect;
        this.relativeXInWord = relX;
        this.relativeYInWord = relY;
        const { lineNumber, positionInLine } = this.getWordLineAndPositionInLine(this.clickWordIndex);
        this.clickLineNumber = lineNumber;
        this.clickPositionInLine = positionInLine;
        this.currentIndex = this.clickWordIndex;
      } else {
        oval.classList.add('blank');
        this.clickWordIndex = -1;
        this.clickWord = null;
        this.clickWordRect = null;
        this.relativeXInWord = null;
        this.relativeYInWord = null;
        this.clickLineNumber = null;
        this.clickPositionInLine = null;
        this.currentIndex = -1;
      }
    },
    onRevealUp() {
      if (!this.isClickHeld) return;
      this.fakeCursorX = this.clickStartX;
      this.fakeCursorY = this.clickStartY;
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
      const itemId = this.$el.querySelector(".item_id").value;
      const trial = this.trials.find(t => String(t.item_id) === String(itemId));
      const totalWordsInItem = trial ? trial.text.split(/\s+/).filter(Boolean).length : null;
      const durationMs = this.clickStartTime != null ? endTime - this.clickStartTime : null;
      const payload = {
        Experiment: expEl.value,
        Condition: this.$el.querySelector(".condition_id").value,
        ItemId: itemId,
        totalWordsInItem,
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
      if (this.clickLineNumber != null) payload.line_number = this.clickLineNumber;
      if (this.clickPositionInLine != null) payload.position_in_line = this.clickPositionInLine;
      payload.mouseMovedMoreThan5Px = this.mouseMovedMoreThan5Px;
      $magpie.addTrialData(payload);
      this.mouseMovedMoreThan5Px = false;
      this.clickStartTime = null;
      this.clickStartX = null;
      this.clickStartY = null;
      this.clickWordIndex = null;
      this.clickWord = null;
      this.clickWordRect = null;
      this.relativeXInWord = null;
      this.relativeYInWord = null;
      this.clickLineNumber = null;
      this.clickPositionInLine = null;
    },
    trackMovementDuringHold(e) {
      if (!this.isClickHeld || this.clickStartX == null || this.clickStartY == null) return;
      const dx = e.clientX - this.clickStartX;
      const dy = e.clientY - this.clickStartY;
      if (Math.sqrt(dx * dx + dy * dy) > 5) this.mouseMovedMoreThan5Px = true;
    },
    moveCursor(e) {
      if (this.showFakeCursor && !this.isClickHeld) {
        this.showFakeCursor = false;
        document.body.style.cursor = '';
      }
      if (this.isClickHeld) return;
      let x = e.clientX;
      let y = e.clientY;
      const elementAtCursor = document.elementFromPoint(x, y) && document.elementFromPoint(x, y).closest('span');
      if (elementAtCursor) {
        this.currentIndex = elementAtCursor.getAttribute('data-index');
      } else {
        const elementAboveCursor = document.elementFromPoint(x, y - 3) && document.elementFromPoint(x, y - 3).closest('span');
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
    toggleDivs(trial) {
      this.showFirstDiv = !this.showFirstDiv;
      if (!this.showFirstDiv && trial && trial.questions && trial.questions.length) {
        this.$set(this.$magpie.measurements, 'responses', Array(trial.questions.length).fill(''));
      }
      this.isCursorMoving = false;
    },
    allResponsesFilled(trial) {
      if (!trial || !trial.questions) return false;
      if (trial.questions.length === 0) return true;
      const r = this.$magpie.measurements.responses;
      return Array.isArray(r) && r.length >= trial.questions.length && trial.questions.every((_, qIdx) => r[qIdx]);
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
    padding-left: 11%;
    padding-right: 11%;
  }
  button {
    position: absolute;
    bottom: 0;
    left: 50%;
  }
  .oval-cursor {
    position: fixed;
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
    height: 13px;
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
  .fake-cursor {
    position: fixed;
    width: 12px;
    height: 12px;
    margin-left: -6px;
    margin-top: -6px;
    border-radius: 50%;
    background: rgba(100, 100, 100, 0.65);
    pointer-events: none;
    z-index: 9999;
    box-shadow: 0 0 0 1px rgba(255, 255, 255, 0.3);
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
    padding-left: 11%;
    padding-right: 11%;
  }

  .comprehension-question {
    margin-bottom: 1.2em;
    text-align: left;
    max-width: 90%;
    margin-left: auto;
    margin-right: auto;
  }
  .question-text {
    font-weight: 500;
    margin-bottom: 0.4em;
  }
  .comprehension-question label {
    display: inline-block;
    margin-right: 1em;
    cursor: pointer;
  }
  * {
    user-select: none; /* Standard syntax */
    -webkit-user-select: none; /* Safari */
    -moz-user-select: none; /* Firefox */
    -ms-user-select: none; /* Internet Explorer/Edge */
    }
</style>
