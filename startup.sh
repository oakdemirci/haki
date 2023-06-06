#! /bin/bash
export PATH="${CONDA_DIR}/bin:$PATH"
conda run -n UHTE jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --notebook-dir=/notebooks &
bash