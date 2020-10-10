library(reticulate)

use_python("/usr/bin/python3")

# load the data that is speech of presidents
load("speech.rda")

# top n frequency
n <- 300

# convert data from vector to vectors
speech_kim <- sort(speech_kim, decreasing = TRUE)[seq(n)]
terms_kim <- names(speech_kim)
freqs_kim <- speech_kim

speech_lee <- sort(speech_lee, decreasing = TRUE)[seq(n)]
terms_lee <- names(speech_lee)
freqs_lee <- speech_lee

speech_noh <- sort(speech_noh, decreasing = TRUE)[seq(n)]
terms_noh <- names(speech_noh)
freqs_noh <- speech_noh

# call the python scripts
py_run_string("
from random import Random
import palettable
from wordcloud import WordCloud, ImageColorGenerator
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt

terms_kim = r.terms_kim
freqs_kim = r.freqs_kim

terms_lee = r.terms_lee
freqs_lee = r.freqs_lee

terms_noh = r.terms_noh
freqs_noh = r.freqs_noh

word_frequency_kim = {terms_kim[i]: freqs_kim[i] for i in range(len(terms_kim))} 
word_frequency_lee = {terms_lee[i]: freqs_lee[i] for i in range(len(terms_lee))} 
word_frequency_noh = {terms_noh[i]: freqs_noh[i] for i in range(len(terms_noh))} 

fpath = '/Users/choonghyunryu/Library/Fonts/NanumSquareBold.ttf'

def custom_color_func(word = None, font_size = None, position = None,
                      orientation = None, font_path = None, random_state = None):
    if random_state is None:
        random_state = Random()
    return 'hsl(%d, 80%%, 50%%)' % random_state.randint(0, 255)

wc = WordCloud(font_path = fpath, background_color = 'white',
               max_words = 1000,
               color_func = custom_color_func,
               width = 1260,
               height = 720,
               random_state = 200)
               
w = wc.generate_from_frequencies(
    word_frequency_kim
)

plt.imshow(w)
plt.axis('off')
plt.savefig('./speech_kim.png', figsize = (7, 4), dpi = 300)

w = wc.generate_from_frequencies(
    word_frequency_lee
)

plt.imshow(w)
plt.axis('off')
plt.savefig('./speech_lee.png', figsize = (7, 4), dpi = 300)

w = wc.generate_from_frequencies(
    word_frequency_noh
)

plt.imshow(w)
plt.axis('off')
plt.savefig('./speech_noh.png', figsize = (7, 4), dpi = 300)
              ")
