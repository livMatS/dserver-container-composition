import os
import glob
import dtoolcore
from dtoolcore import DataSetCreator

# copy those datasets to remote location
for dataset in dtoolcore.iter_datasets_in_base_uri('/datasets'):
    dtoolcore.copy(dataset.uri, 'smb://test-share')

