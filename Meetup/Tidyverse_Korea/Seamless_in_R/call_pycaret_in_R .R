library(reticulate)

use_python("/usr/bin/python3")

pcaret_data <- import("pycaret.datasets", as = "pd", convert = FALSE)
juice <- pcaret_data$get_data("juice")
juice <- reticulate::py_to_r(juice)

pcaret_model <- import("pycaret.classification", as = "pcaret", convert = FALSE)

#intialize the setup (in Non-Notebook env)
exp_clf = pcaret_model$setup(juice, target = 'Purchase', html = FALSE)


# return best model
best = pcaret_model$compare_models()

# create individual models for stacking
ridge = pcaret_model$create_model('ridge')
lda = pcaret_model$create_model('lda')
gbc = pcaret_model$create_model('gbc')
xgboost = pcaret_model$create_model('xgboost')

# stacking models
stacker = pcaret_model$stack_models(estimator_list = list(ridge, lda, gbc), 
                                    meta_model = xgboost)

pcaret_model$plot_model(stacker)

