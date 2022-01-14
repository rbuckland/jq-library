# A Generalised jq data library

Features

  * A. Convert Structured JSON Objects to CSV (preserving nested structure)
  * B. Convert CSV file, normal or nested structure (from A) to structured CSV.


## Example

* Object to CSV
```
jq-library on  main [?] 
❯ cat test/data/abc-no-array.json 
[
    {
        "arr": [ "foo", "bar" , "baz" ],
        "something": "here",
        "someproperty": "there",
        "a": {
            "b": {
                "c": 1234
            }
        },
        "extra-only-here": true
    },

    {
        "arr": [ 8, 7 , 6 ],
        "something": "here",
        "someproperty": "there",
        "a": {
            "b": {
                "c": 1234
            }
        },
        "extra-only-here": true
    },
    {
        "something": "here",
        "someproperty": "there",
        "arr": [ 1, 2, 3, 4],
        "a": {
            "b": {
                "c": 1234
            }
        }
    }
]

```                           

* CSV to Object

  Take note of the "padded" row alligned Arrays, because another array was longer. 
  May remove that "feature".

```
jq-library on  main [?]
❯ jq -r 'include "data-conversion"; arr_objects_to_csv' < test/data/abc-no-array.json | jq -r --slurp --raw-input 'include "data-conversion"; csv_to_json'
[
  {
    "arr": [
      "foo",
      "bar",
      "baz",
      null
    ],
    "something": "here",
    "someproperty": "there",
    "a": {
      "b": {
        "c": 1234
      }
    },
    "extra-only-here": "true"
  },
  {
    "arr": [
      8,
      7,
      6,
      null
    ],
    "something": "here",
    "someproperty": "there",
    "a": {
      "b": {
        "c": 1234
      }
    },
    "extra-only-here": "true"
  },
  {
    "arr": [
      1,
      2,
      3,
      4
    ],
    "something": "here",
    "someproperty": "there",
    "a": {
      "b": {
        "c": 1234
      }
    },
    "extra-only-here": null
  }
]

```

## Testing 

```
jq -nr -f test_data-conversion.jq
```