# ====================================================================
# Setting up Environment
# ====================================================================

#import the dataset from pycaret repository 
from pycaret.datasets import get_data 
juice = get_data('juice') 

#import classification module 
from pycaret.classification import * 

#intialize the setup (in Notebook env)
exp_clf = setup(juice, target = 'Purchase')

#intialize the setup (in Non-Notebook env)
exp_clf = setup(juice, target = 'Purchase', html = False)

#intialize the setup (remote runs like Kaggle or GitHub actions)
exp_clf = setup(juice, target = 'Purchase', silent = True)



# ====================================================================
# Compare Models
# ====================================================================

# return best model
best = compare_models()

# return best model based on AUC
best = compare_models(sort = 'AUC') #default is 'Accuracy'

# compare specific models
best_specific = compare_models(whitelist = ['dt','rf','xgboost'])

# blacklist certain models
best_specific = compare_models(blacklist = ['catboost', 'svm'])

# return top 3 models based on 'Accuracy'
top3 = compare_models(n_select = 3)



# ====================================================================
# Create Model
# ====================================================================

# train logistic regression model
lr = create_model('lr') #lr is the id of the model

# check the model library to see all models
models()

# train rf model using 5 fold CV
rf = create_model('rf', fold = 5)

# train svm model without CV
svm = create_model('svm', cross_validation = False)

# train xgboost model with max_depth = 10
xgboost = create_model('xgboost', max_depth = 10)

# train xgboost model on gpu
xgboost_gpu = create_model('xgboost', tree_method = 'gpu_hist', gpu_id = 0) #0 is gpu-id

# train multiple lightgbm models with n learning_rate<br>import numpy as np
lgbms = [create_model('lightgbm', learning_rate = i) for i in np.arange(0.1,1,0.1)]

# train custom model
from gplearn.genetic import SymbolicClassifier
symclf = SymbolicClassifier(generation = 50)
sc = create_model(symclf)



# ====================================================================
# Tune Model
# ====================================================================

# train a decision tree model with default parameters
dt = create_model('dt')

# tune hyperparameters of decision tree
tuned_dt = tune_model(dt)

# tune hyperparameters with increased n_iter
tuned_dt = tune_model(dt, n_iter = 50)

# tune hyperparameters to optimize AUC
tuned_dt = tune_model(dt, optimize = 'AUC') #default is 'Accuracy'

# tune hyperparameters with custom_grid
params = {"max_depth": np.random.randint(1, (len(data.columns)*.85),20),
          "max_features": np.random.randint(1, len(data.columns),20),
          "min_samples_leaf": [2,3,4,5,6],
          "criterion": ["gini", "entropy"]
          }

tuned_dt_custom = tune_model(dt, custom_grid = params)

# tune multiple models dynamically
top3 = compare_models(n_select = 3)
tuned_top3 = [tune_model(i) for i in top3]



# ====================================================================
# Ensemble Model
# ====================================================================

# create a decision tree model
dt = create_model('dt') 

# ensemble decision tree model with 'Bagging'
bagged_dt = ensemble_model(dt)

# ensemble decision tree model with 'Bagging' with 100 n_estimators
bagged_dt = ensemble_model(dt, n_estimators = 100)

# ensemble decision tree model with 'Boosting'
boosted_dt = ensemble_model(dt, method = 'Boosting')



# ====================================================================
# Blend Models
# ====================================================================

# train a votingclassifier on all models in library
blender = blend_models()

# train a voting classifier on specific models
dt = create_model('dt')
rf = create_model('rf')
adaboost = create_model('ada')
blender_specific = blend_models(estimator_list = [dt,rf,adaboost], method = 'soft')

# train a voting classifier dynamically
blender_top5 = blend_models(compare_models(n_select = 5))



# ====================================================================
# Stack Models
# ====================================================================

# train indvidual models for stacking
dt = create_model('dt')
rf = create_model('rf')
ada = create_model('ada')
ridge = create_model('ridge')
knn = create_model('knn')

# stack trained models
stacked_models = stack_models(estimator_list=[dt,rf,ada,ridge,knn])

# stack trained models dynamically
top7 = compare_models(n_select = 7)
stacked_models = stack_models(estimator_list = top7[1:], meta_model = top7[0])


# ====================================================================
# Create Stacknet
# ====================================================================

# train individual models for stacknet
dt = create_model('dt')
rf = create_model('rf')
ada = create_model('ada')
ridge = create_model('ridge')
knn = create_model('knn')

# create stacknet
stacknet = create_stacknet(estimator_list =[[dt,rf],[ada,ridge,knn]])



# ====================================================================
# Plot Model
# ====================================================================

#create a model
lr = create_model('lr')

#plot a model
plot_model(lr)



# ====================================================================
# Evaluate Model
# ====================================================================

#create a model
lr = create_model('lr')

#evaluate a model
evaluate_model(lr)



# ====================================================================
# Interpret Model
# ====================================================================

# create a model
dt = create_model('dt')

# interpret overall model 
interpret_model(dt)

# correlation shap plot
interpret_model(dt, plot = 'correlation')

# interactive reason plot
interpret_model(dt, plot = 'reason')

# reason plot at observation level
interpret_model(dt, plot = 'reason', observation = 1) #observation 1 for testset



# ====================================================================
# Calibrate Model
# ====================================================================

#create a boosting model
dt_boosted = create_model('dt', ensemble = True, method = 'Boosting')

#calibrate trainde boosted dt
calibrated_dt = calibrate_model(dt_boosted)




# ====================================================================
# Optimize Threshold
# ====================================================================

#create a model
lr = create_model('lr')

#optimize threshold for trained model
optimize_threshold(lr, true_negative = 10, false_negative = -100)



# ====================================================================
# Predict Model
# ====================================================================

# train logistic regression model
lr = create_model('lr')

# predictions on hold-out set
lr_pred_holdout = predict_model(lr)

# predictions on new dataset
lr_pred_new = predict_model(lr, data = new_data) #new_data is pd dataframe



# ====================================================================
# Finalize Model
# ====================================================================

#create a model
lr = create_model('lr')

#finalize trained model
finalize_model(lr)



# ====================================================================
# Deploy Model
# ====================================================================

#create a model
lr = create_model('lr')

#deploy trained model on cloud
deploy_model(model = lr, model_name = 'deploy_lr', platform = 'aws', authentication = {'bucket' : 'pycaret-test'})



# ====================================================================
# Save Model
# ====================================================================

#create a model
lr = create_model('lr')

#save trained model
save_model(lr, 'lr_model_23122019')



# ====================================================================
# Load Model
# ====================================================================

saved_lr = load_model('lr_model_23122019')




# ====================================================================
# AutoML
# ====================================================================

# selecting best model
best = automl()




# ====================================================================
# Pull
# ====================================================================

# store score grid in dataframe 
df = pull()




# ====================================================================
# Models
# ====================================================================

# show all models in library 
all_models = models()



# ====================================================================
# Get Logs
# ====================================================================

# store experiment logs in pandas dataframe
logs = get_logs()


# ====================================================================
# Get Config
# ====================================================================

# get X_train dataframe
X_train = get_config('X_train') 




# ====================================================================
# Set Config
# ====================================================================

# change seed value in environment to '999'
set_config('seed', 999)



# ====================================================================
# Get System Logs
# ====================================================================

# Reading system logs in Notebook
get_system_logs()



# ====================================================================
# MLFlow UI
# ====================================================================

# loading dataset
from pycaret.datasets import get_data
data = get_data('diabetes')

# initializing setup
from pycaret.classification import *
clf1 = setup(data, target = 'Class variable', log_experiment = True, experiment_name = 'diabetes1')

# compare all baseline models and select top 5
top5 = compare_models(n_select = 5) 

# tune top 5 base models
tuned_top5 = [tune_model(i) for i in top5]

# ensemble top 5 tuned models
bagged_top5 = [ensemble_model(i) for i in tuned_top5]

# blend top 5 base models 
blender = blend_models(estimator_list = top5) 

# run mlflow server (notebook)
!mlflow ui

### just 'mlflow ui' when running through command line.




