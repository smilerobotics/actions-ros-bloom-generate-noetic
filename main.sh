#!/bin/bash -ex
if [[ "_${ROS_DISTRO}" == "_melodic" ]]; then
  PIP_PACKAGE=python-pip
  PIP_COMMAND=pip
else
  PIP_PACKAGE=python3-pip
  PIP_COMMAND=pip3
fi

mkdir -p "${GITHUB_WORKSPACE}/${OUTPUT_DIR}"

apt-get update
apt-get upgrade -y
apt-get install -y fakeroot "${PIP_PACKAGE}" dpkg-dev debhelper libxml2-utils
"${PIP_COMMAND}" install -U bloom

if [[ ! -z "${SETUP_DEPENDENCIES_SCRIPT_PATH}" ]]; then
  "${SETUP_DEPENDENCIES_SCRIPT_PATH}"
else
  rosdep update
  rosdep install --from-paths "${SOURCE_DIR}" --ignore-src -y
fi

source "/opt/ros/${ROS_DISTRO}/setup.bash"
for target in ${TARGETS}; do
  pushd "${SOURCE_DIR}/${target}"
  bloom-generate rosdebian --ros-distro "${ROS_DISTRO}"
  fakeroot debian/rules binary
  dpkg -i ../*.deb
  echo "$(xmllint --xpath '/package/name/text()' package.xml):
  ubuntu: [$(basename ../*.deb | cut -f 1 -d _)]" >>/tmp/rosdep.yaml
  echo "yaml file:///tmp/rosdep.yaml" >/etc/ros/rosdep/sources.list.d/19-custom.list
  rosdep update
  mv ../*.deb "${GITHUB_WORKSPACE}/${OUTPUT_DIR}"
  popd
done

mv /tmp/rosdep.yaml "${GITHUB_WORKSPACE}/${OUTPUT_DIR}"

pushd "${GITHUB_WORKSPACE}"
echo "::set-output name=deb_files::$(echo $(find "${OUTPUT_DIR}" -name '*\.deb' -exec echo \${GITHUB_WORKSPACE}/{} \;))"
echo "::set-output name=rosdep_file::$(find "${OUTPUT_DIR}" -name "rosdep.yaml" -exec echo \${GITHUB_WORKSPACE}/{} \;)"
echo "::set-output name=output_dir::$(echo \${GITHUB_WORKSPACE}/${OUTPUT_DIR})"
