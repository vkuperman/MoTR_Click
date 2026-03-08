# Trial files

TSV columns: `experiment`, `experiment_id`, `condition`, `condition_id`, `item_id`, `text`, `question`, `response_true`, `response_distractors`.

## Single question (legacy)

One row per item. The single `question` is shown with options from `response_true` and `response_distractors` (pipe-separated). This is treated as one **multiple_choice** question.

## Multiple questions (optional `questions` column)

Add a column **`questions`** with a JSON array. Each element can be:

- **Yes/no:** `{"type":"yes_no","question":"Was the character afraid?","correct":"No"}`
- **Multiple choice:** `{"type":"multiple_choice","question":"What did X do?","correct":"Option A","options":["Option A","Option B","Option C"]}`

Example (one yes/no and one multiple choice):

```json
[{"type":"yes_no","question":"Did Richard Carrington observe moon spots?","correct":"No"},{"type":"multiple_choice","question":"What did he see?","correct":"patches of light","options":["patches of light","moon spots","nothing"]}]
```

In the TSV, put this in a single cell (escape quotes if required by your TSV format). The app will parse it and show all questions for that item; responses are saved in `responses` (array) per trial.
