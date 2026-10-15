# Predicting exercise quality from wearable sensors

Practical Machine Learning — Prediction Assignment Writeup  
Prepared 15 October 2026. AI-assisted analysis for learner review.

## Objective and data

Predict the five-category `classe` outcome from belt, arm, forearm and dumbbell measurements. The supplied training file contains 19,622 labeled observations from six participants; the separate assessment file has 20 observations without labels. Class counts A–E are 5,580, 3,797, 3,422, 3,216 and 3,607. This is a classification problem, not a causal estimate of training effectiveness.

## Cleaning and leakage controls

Empty strings, `NA` and `#DIV/0!` are missing values. Exclude row identifiers, participant names, raw/formatted timestamps, `new_window` and `num_window` from predictors. Identifiers and timing fields could encode acquisition order rather than exercise mechanics. Exclude variables with at least 5% missingness and nonnumeric or constant fields. This leaves 52 numeric sensor measurements, complete in both files, so no imputation or scaling is needed. Feature availability is assessed from the labeled training file; the assessment file is used only for schema checks and final predictions. Its outcomes are never observed. Tree methods do not require standardized units.

Measurements within one recording window are related. Group identifiers combine participant and `num_window`; all rows from one group remain in a single split. Using seed 20261015, reserve 25% of groups using GroupShuffleSplit: 14,644 development rows in 643 groups and 4,978 validation rows in 215 disjoint groups. Splits are not stratified; the saved row-level split file makes the exact split auditable.

## Model building and cross-validation

Compare an unconstrained CART decision tree with a 150-tree random forest, using square-root feature subsampling and otherwise library defaults. The forest averages diverse trees, captures nonlinear interactions and usually reduces the instability of a single tree. Three-fold GroupKFold cross-validation operates only inside the development partition and retains entire windows in each fold. Select by mean accuracy; do not select using the held-out validation results. There is no broad hyperparameter search or iterative tuning against the holdout.

| Model | Fold 1 accuracy | Fold 2 accuracy | Fold 3 accuracy | Mean accuracy |
|---|---|---|---|---|
| Decision tree | 78.86% | 80.21% | 84.88% | 81.32% |
| Random forest | 89.94% | 90.80% | 93.73% | 91.49% |

The random forest wins with mean cross-validation accuracy 91.49%. Fold variation is relevant: it reflects differences in held-out windows and available training size, not a confidence interval for deployment accuracy.

## Held-out performance and expected error

Fit the selected 150-tree forest on development rows and evaluate once on the reserved windows. Accuracy is **95.70%**, with **214 errors out of 4,978**. The estimated out-of-sample misclassification rate for comparable new windows from this collection is therefore **4.30%**. Three-fold development CV gives a more conservative error of 8.51%; its folds train on fewer observations and contain different windows. These estimates should be reported together rather than choosing the most favorable number.

Confusion matrix: rows are actual classes; columns are predictions.

| Actual / predicted | A | B | C | D | E |
|---|---|---|---|---|---|
| A | 1534 | 11 | 0 | 0 | 0 |
| B | 24 | 714 | 33 | 0 | 2 |
| C | 0 | 3 | 932 | 64 | 0 |
| D | 9 | 0 | 25 | 802 | 2 |
| E | 1 | 3 | 31 | 6 | 782 |

The largest off-diagonal count is 64 true C observations classified as D. Overall accuracy hides such class-specific differences; the repository includes a full precision/recall report.

## Limits of generalization

This validation prevents exact recording-window overlap but includes the same participants across partitions. It is not leave-one-person-out testing, and adjacent windows may remain correlated. Only six people were measured, so accuracy on new people, new sessions, other devices or other exercises could be materially lower. A row-independent binomial interval would understate uncertainty when rows are correlated, so no such interval is used as a deployment guarantee. Further evaluation should hold out participants or independent sessions. Neither the 20 unlabeled assessment cases nor the previously completed quiz provides an independently measured accuracy for this fitted model.

## Final model and 20 assessment cases

After evaluation, refit the same selected forest family on all 19,622 labeled rows, increasing the tree count to 300 for the final predictions and retaining square-root feature subsampling and the seed. No assessment labels or scores influence fitting. The saved `Test_predictions.csv` contains one prediction for each `problem_id`; it does not overwrite the already passed Coursera quiz. The validation estimate belongs to the 150-tree development fit; it is an approximation for, not a fresh evaluation of, the final refit.

## Reproducibility

The submitted Markdown source (`Prediction_Writeup.md`) and its compiled HTML (`Prediction_Writeup.html`) accompany `analyze.py`, package versions, split assignments, metrics and the confusion matrix. The analysis was actually executed in Python 3.12.14 with scikit-learn 1.9.1, pandas 2.2.3 and NumPy 2.5.4. No unexecuted R output is claimed. The submission form accepts a `.md` source plus compiled HTML. Download the HTML to read it locally if GitHub displays its source.

To reproduce, install `requirements.txt`, place the two original CSVs in `Data`, and run `python Code/analyze.py`. The script saves exact numerical outputs in `Reports`. Random seeds and all partition/model choices are explicit. Parallel floating-point/library differences may cause minor version-dependent variation.

## Sources and attribution

Dataset: Weight Lifting Exercises, Human Activity Recognition project, PUC-Rio: http://groupware.les.inf.puc-rio.br/har (archived site linked in the assignment). Original project description: Velloso, E.; Bulling, A.; Gellersen, H.; Ugulino, W.; Fuks, H. (2013), “Qualitative Activity Recognition of Weight Lifting Exercises,” AH '13, pp. 116–123, doi:10.1145/2459236.2459256.

Course-provided files: https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv and https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv . Assignment: Johns Hopkins University, Practical Machine Learning, Prediction Assignment Writeup. Accessed 15 October 2026.
