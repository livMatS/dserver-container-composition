#!/bin/bash
test_dataset_uris=$(dtool ls -q volumes/test_datasets)
num_entries=$(echo "$test_dataset_uris" | wc -l)
echo "Processing ${num_entries} datasets..."
counter=0

fifth_num_entries=$((num_entries / 5))
quarter_num_entries=$((num_entries / 4))
third_num_entries=$((num_entries / 3))
half_num_entries=$((num_entries / 2))

for uri in ${test_dataset_uris}; do
  test_dataset_path=$(echo "${uri}" | sed -e "s|^file://[^/]*/|/|" )
  ((counter++))
  # echo ${test_dataset_path}

  # tag first half
  if ((counter < half_num_entries)); then
      echo "dtool tag set '${test_dataset_path}' 'first-half'"
      dtool tag set "${test_dataset_path}" "first-half"
  fi

  # tag second third
  if ((counter > third_num_entries && counter <= 2*third_num_entries)); then
      echo "dtool tag set '${test_dataset_path}' 'second-third'"
      dtool tag set "${test_dataset_path}" "second-third"
  fi

  # annotate 3rd quarter
  if ((counter > 2*quarter_num_entries && counter <= 3*quarter_num_entries)); then
      echo "dtool annotation set '${test_dataset_path}' 'chunk' 'third-quarter'"
      dtool annotation set "${test_dataset_path}" "chunk" "third-quarter" 
  fi

  # annotate 3rd fifth
  if ((counter > 2*fifth_num_entries && counter <= 3*fifth_num_entries)); then
      echo "dtool annotation set '${test_dataset_path}' 'number' ${counter}"
      dtool annotation set "${test_dataset_path}" "number" ${counter}
  fi
done

