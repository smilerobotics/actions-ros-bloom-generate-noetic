# ros-bloom-generate-noetic

## Description

An action to run [bloom-generate](https://github.com/ros-infrastructure/bloom) command and generate deb files for ROS packages on ROS noetic / Ubuntu-20.04.

## Required input

1. targets: Space separated list of directories of package.xml. Path should be relative to source_dir.
1. source_dir: Path of the top directory of sources.
1. output_dir: Path of the directory to which the deb files will be copied. Realtive to GITHUB_WORKSPACE.
1. setup_dependencies_script_path: Path of the script to be executed before bloom-generate. rosdep install will be executed in the default script.

## Output

1. deb_files: Path of the deb files.
1. rosdep_file: Path of the rosdep file.
1. output_dir: Path of the output directory.

## Example

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          repository: smilerobotics/rplidar_ros
          ref: reconfigure
          path: ./src/rplidar_ros
      - uses: smilerobotics/actions-ros-bloom-generate-noetic@v1
        with:
          source_dir: ./src
          targets: ./rplidar_ros
          output_dir: ./debs
        id: generate
```
