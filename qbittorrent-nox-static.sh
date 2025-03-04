#!/usr/bin/env bash
#
# Copyright 2020 by userdocs and contributors
#
# SPDX-License-Identifier: Apache-2.0
#
# @author - userdocs
#
# @contributors IceCodeNew Stanislas boredazfcuk AdvenT. guillaumedsde
#
# @credits - https://gist.github.com/notsure2 https://github.com/c0re100/qBittorrent-Enhanced-Edition
#
# shellcheck disable=SC2034,SC1091 # Why are these checks excluded?
#
# https://github.com/koalaman/shellcheck/wiki/SC2034 There are quite a few variables defined by combining other variables that mean nothing on their own. This behavior is intentional and the warning can be skipped.
#
# https://github.com/koalaman/shellcheck/wiki/SC1091 I am sourcing /etc/os-release for some variables. It's not available to shellcheck to source and it's a safe file so we can skip this
#
# Script Formatting - https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format
#
#######################################################################################################################################################
# Set some script features - https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
#######################################################################################################################################################
set -a
#######################################################################################################################################################
# Unset some variables to set defaults.
#######################################################################################################################################################
unset qbt_skip_delete qbt_skip_icu qbt_git_proxy qbt_curl_proxy qbt_install_dir qbt_build_dir qbt_working_dir qbt_modules_test qbt_python_version
#######################################################################################################################################################
# Color me up Scotty - define some color values to use as variables in the scripts.
#######################################################################################################################################################
cr="\e[31m" && clr="\e[91m" # [c]olor[r]ed     && [c]olor[l]ight[r]ed
cg="\e[32m" && clg="\e[92m" # [c]olor[g]reen   && [c]olor[l]ight[g]reen
cy="\e[33m" && cly="\e[93m" # [c]olor[y]ellow  && [c]olor[l]ight[y]ellow
cb="\e[34m" && clb="\e[94m" # [c]olor[b]lue    && [c]olor[l]ight[b]lue
cm="\e[35m" && clm="\e[95m" # [c]olor[m]agenta && [c]olor[l]ight[m]agenta
cc="\e[36m" && clc="\e[96m" # [c]olor[c]yan    && [c]olor[l]ight[c]yan
#
tb="\e[1m" && td="\e[2m" && tu="\e[4m" && tn="\n" # [t]ext[b]old && [t]ext[d]im && [t]ext[u]nderlined && [t]ext[n]ewline
#
utick="\e[32m\U2714\e[0m" && uplus="\e[36m\U002b\e[0m" && ucross="\e[31m\U00D7\e[0m" # [u]nicode][tick] [u]nicode][plus] [u]nicode][cross]
#
urc="\e[31m\U25cf\e[0m" && ulrc="\e[91m\U25cf\e[0m"    # [u]nicode[r]ed[c]ircle     && [u]nicode[l]ight[r]ed[c]ircle
ugc="\e[32m\U25cf\e[0m" && ulgc="\e[92m\U25cf\e[0m"    # [u]nicode[g]reen[c]ircle   && [u]nicode[l]ight[g]reen[c]ircle
uyc="\e[33m\U25cf\e[0m" && ulyc="\e[93m\U25cf\e[0m"    # [u]nicode[y]ellow[c]ircle  && [u]nicode[l]ight[y]ellow[c]ircle
ubc="\e[34m\U25cf\e[0m" && ulbc="\e[94m\U25cf\e[0m"    # [u]nicode[b]lue[c]ircle    && [u]nicode[l]ight[b]lue[c]ircle
umc="\e[35m\U25cf\e[0m" && ulmc="\e[95m\U25cf\e[0m"    # [u]nicode[m]agenta[c]ircle && [u]nicode[l]ight[m]agenta[c]ircle
ucc="\e[36m\U25cf\e[0m" && ulcc="\e[96m\U25cf\e[0m"    # [u]nicode[c]yan[c]ircle    && [u]nicode[l]ight[c]yan[c]ircle
ugrc="\e[37m\U25cf\e[0m" && ulgrcc="\e[97m\U25cf\e[0m" # [u]nicode[gr]ey[c]ircle    && [u]nicode[l]ight[gr]ey[c]ircle
#
cdef="\e[39m" # [c]olor[def]ault
cend="\e[0m"  # [c]olor[end]
#######################################################################################################################################################
# Check we are on a supported OS and release.
#######################################################################################################################################################
what_id="$(source /etc/os-release && printf "%s" "${ID}")"                             # Get the main platform name, for example: debian, ubuntu or alpine
what_version_codename="$(source /etc/os-release && printf "%s" "${VERSION_CODENAME}")" # Get the codename for this this OS. Note, Alpine does not have a unique codename.
what_version_id="$(source /etc/os-release && printf "%s" "${VERSION_ID%_*}")"          # Get the version number for this codename, for example: 10, 20.04, 3.12.4
#
if [[ "${what_id}" =~ ^(alpine)$ ]]; then # If alpine, set the codename to alpine. We check for min v3.10 later with codenames.
	what_version_codename="alpine"
fi
#
## Check against allowed codenames or if the codename is alpine version greater thab 3.10
if [[ ! "${what_version_codename}" =~ ^(alpine|buster|bullseye|bionic|focal|hirsute)$ ]] || [[ "${what_version_codename}" =~ ^(alpine)$ && "${what_version_id//\./}" -lt "3100" ]]; then
	echo
	echo -e " ${cly}This is not a supported OS. There is no reason to continue.${cend}"
	echo
	echo -e " id: ${td}${cly}${what_id}${cend} codename: ${td}${cly}${what_version_codename}${cend} version: ${td}${clr}${what_version_id}${cend}"
	echo
	echo -e " ${td}These are the supported platforms${cend}"
	echo
	echo -e " ${clm}Debian${cend} - ${clb}buster${cend}"
	echo
	echo -e " ${clm}Ubuntu${cend} - ${clb}bionic${cend} - ${clb}focal${cend}"
	echo
	echo -e " ${clm}Alpine${cend} - ${clb}3.10.0${cend} or greater"
	echo
	exit 1
fi
#######################################################################################################################################################
# This function sets some default values we use but whose values can be overridden by certain flags
#######################################################################################################################################################
set_default_values() {
	DEBIAN_FRONTEND="noninteractive" && TZ="Europe/London" # For docker deploys to not get prompted to set the timezone.
	#
	qbt_build_tool="${qbt_build_tool:-}"
	qbt_cross_name="${qbt_cross_name:-}"
	qbt_cross_target="${qbt_cross_target:-${what_id}}"
	qbt_cmake_debug="${qbt_cmake_debug:-}"
	#
	qbt_patches_url="${qbt_patches_url:-}" # Provide a git username and repo in this format - username/repo" - In this repo the structure needs to be like this /patches/libtorrent/1.2.11/patch and/or /patches/qbittorrent/4.3.1/patch and your patch file will be automatically fetched and loadded for those matching tags.
	#
	libtorrent_version="${libtorrent_version:-1.2}" # Set this here so it is easy to see and change
	#
	qbt_qt_version=${qbt_qt_version:-5.15} # Set this here so it is easy to see and change. PATCH versions are detected automatically - 5.15.2 will be used over 5.15.0
	#
	[[ "${qbt_qt_version}" =~ ^6\. ]] && qbt_use_qt6="ON" || qbt_use_qt6="OFF" # this automatically toggles the use of QT6 with qbittorrent and cmake
	#
	qbt_python_version="3" # We are only using python3 but it's easier to just change this if we need to.
	#
	standard="17" && cpp_standard="c${standard}" && cxx_standard="c++${standard}" # ${standard} - Set the CXX standard. You need to set c++14 for older version of some apps, like qt 5.12
	#
	CDN_URL="http://dl-cdn.alpinelinux.org/alpine/edge/main" # for alpine
	#
	qbt_modules=("all" "install" "libexecinfo" "bison" "gawk" "glibc" "zlib" "iconv" "icu" "openssl" "boost" "libtorrent" "qtbase" "qttools" "qbittorrent") # Define our list of available modules in an array.
	#
	delete=() # Create this array empty. Modules listed in or added to this array will be removed from the default list of modules, changing the behaviour of all or install
	#
	delete_pkgs=() # Create this array empty. Packages listed in or added to this array will be removed from the default list of packages, changing the list of installed dependencies
	#
	if [[ ${qbt_cross_name} =~ ^(armhf|armv7|aarch64)$ ]]; then
		_multi_arch bootstrap
	else
		cross_arch="$(uname -m)"
		delete_pkgs+=("crossbuild-essential-${cross_arch}")
	fi
	#
	if [[ "${what_id}" =~ ^(alpine)$ ]]; then # if Alpine then delete modules we don't use and set the required packages array
		delete+=("bison" "gawk" "glibc")
		qbt_required_pkgs=("bash" "bash-completion" "build-base" "curl" "pkgconf" "autoconf" "automake" "libtool" "git" "perl" "python${qbt_python_version}" "python${qbt_python_version}-dev" "py${qbt_python_version}-numpy" "py${qbt_python_version}-numpy-dev" "linux-headers" "ttf-freefont" "graphviz" "cmake" "re2c")
	fi
	#
	if [[ "${what_id}" =~ ^(debian|ubuntu)$ ]]; then # if debian based then set the required packages array
		delete+=("libexecinfo")
		qbt_required_pkgs=("build-essential" "crossbuild-essential-${cross_arch}" "curl" "pkg-config" "automake" "libtool" "git" "perl" "python${qbt_python_version}" "python${qbt_python_version}-dev" "python${qbt_python_version}-numpy" "unzip" "graphviz")
	fi
	#
	if [[ "${1}" != 'install' ]]; then # remove this module by default unless provided as a first argument to the script.
		delete+=("install")
	fi
	#
	if [[ "${*}" =~ ([[:space:]]|^)"icu"([[:space:]]|$) ]]; then # Don't remove the icu module if it was provided as a positional parameter.
		qbt_skip_icu='no'
	elif [[ "${qbt_skip_icu}" != 'no' ]]; then # else skip icu by default unless the -i flag is provided.
		delete+=("icu")
	fi
	#
	if [[ "${qbt_build_tool}" != 'cmake' ]]; then
		delete_pkgs+=("unzip" "ttf-freefont" "graphviz" "cmake" "re2c")
	else
		[[ "${qbt_skip_icu}" != 'no' ]] && delete+=("icu")
	fi
	#
	qbt_working_dir="$(printf "%s" "$(pwd <(dirname "${0}"))")" # Get the full path to the scripts location to use with setting some path related variables.
	qbt_working_dir_short="${qbt_working_dir/$HOME/\~}"         # Used with echos. Use the qbt_working_dir variable but the $HOME path is replaced with a literal ~
	#
	qbt_install_dir="${qbt_working_dir}/qbt-build"      # install relative to the script location.
	qbt_install_dir_short="${qbt_install_dir/$HOME/\~}" # Used with echos. Use the qbt_install_dir variable but the $HOME path is replaced with a literal ~
	#
	qbt_local_paths="$PATH" # get the local users $PATH before we isolate the script by setting HOME to the install dir in the set_build_directory function.
}
#######################################################################################################################################################
# This function will check for a list of defined dependencies from the qbt_required_pkgs array. Apps like python3-dev are dynamically set
#######################################################################################################################################################
check_dependencies() {
	echo -e "${tn} ${ulbc} ${tb}Checking if required core dependencies are installed${cend}${tn}"
	#
	## remove packages in the delete_pkgs from the qbt_required_pkgs array
	for target in "${delete_pkgs[@]}"; do
		for i in "${!qbt_required_pkgs[@]}"; do
			if [[ "${qbt_required_pkgs[i]}" = "${target}" ]]; then
				unset 'qbt_required_pkgs[i]'
			fi
		done
	done
	#
	for pkg in "${qbt_required_pkgs[@]}"; do
		#
		if [[ "${what_id}" =~ ^(alpine)$ ]]; then
			pkgman() { apk info -e "${pkg}"; }
		fi
		#
		if [[ "${what_id}" =~ ^(debian|ubuntu)$ ]]; then
			pkgman() { dpkg -s "${pkg}"; }
		fi
		#
		if pkgman > /dev/null 2>&1; then
			echo -e " Dependency ${utick} ${pkg}"
		else
			if [[ -n "${pkg}" ]]; then
				deps_installed='no'
				echo -e " Dependency ${ucross} ${pkg}"
				qbt_checked_required_pkgs+=("$pkg")
			fi
		fi
	done
	#
	if [[ "${deps_installed}" = 'no' ]]; then # Check if user is able to install the dependencies, if yes then do so, if no then exit.
		if [[ "$(id -un)" = 'root' ]]; then
			echo -e "${tn} ${uplus} ${cg}Updating${cend}${tn}"
			#
			if [[ "${what_id}" =~ ^(alpine)$ ]]; then
				apk update --repository="${CDN_URL}"
				apk upgrade --repository="${CDN_URL}"
				apk fix
			fi
			#
			if [[ "${what_id}" =~ ^(debian|ubuntu)$ ]]; then
				apt-get update -y
				apt-get upgrade -y
				apt-get autoremove -y
			fi
			#
			[[ -f /var/run/reboot-required ]] && {
				echo -e "${tn}${cr} This machine requires a reboot to continue installation. Please reboot now.${cend}${tn}"
				exit
			}
			#SS
			echo -e "${tn} ${uplus} ${cg}Installing required dependencies${cend}${tn}"
			#
			if [[ "${what_id}" =~ ^(alpine)$ ]]; then
				if ! apk add "${qbt_checked_required_pkgs[@]}" --repository="${CDN_URL}"; then
					echo
					exit 1
				fi
			fi
			#
			if [[ "${what_id}" =~ ^(debian|ubuntu)$ ]]; then
				if ! apt-get install -y "${qbt_checked_required_pkgs[@]}"; then
					echo
					exit 1
				fi
			fi
			#
			echo -e "${tn} ${utick} ${cg}Dependencies installed!${cend}"
			#
			deps_installed='yes'
		else
			echo -e "${tn}${tb} Please request or install the missing core dependencies before using this script${cend}"
			#
			if [[ "${what_id}" =~ ^(alpine)$ ]]; then
				echo -e "${tn} ${clr}apk add${cend} ${qbt_checked_required_pkgs[*]}${tn}"
			fi
			#
			if [[ "${what_id}" =~ ^(debian|ubuntu)$ ]]; then
				echo -e "${tn} ${clr}apt-get install -y${cend} ${qbt_checked_required_pkgs[*]}${tn}"
			fi
			#
			exit
		fi
	fi
	#
	## All checks passed echo
	if [[ "${deps_installed}" != 'no' ]]; then
		echo -e "${tn} ${ugc} ${tb}All checks passed and core dependencies are installed, continuing to build${cend}"
	fi
}
#######################################################################################################################################################
# 1: curl and git http/https proxy detection use -p username:pass@URL:PORT or -p URL:PORT
#######################################################################################################################################################
while (("${#}")); do
	case "${1}" in
		-b | --build-directory)
			qbt_build_dir="${2}"
			shift 2
			;;
		-bv | --boost-version)
			if [[ -n "${2}" ]]; then
				boost_version="${2}"
				shift 2
			else
				echo
				echo -e " ${ulrc} You must provide a valid arch option when using${cend} ${clb}-bv${cend}"
				echo
				exit 1
			fi
			shift
			;;
		-c | --cmake)
			qbt_build_tool="cmake"
			shift
			;;
		-i | --icu)
			qbt_skip_icu='no'
			[[ "${qbt_skip_icu}" = 'no' ]] && delete=("${delete[@]/icu/}")
			shift
			;;
		-p | --proxy)
			qbt_git_proxy="${2}"
			qbt_curl_proxy="${2}"
			shift 2
			;;
		-ma | --multi-arch)
			if [[ -n "${2}" && "${2}" =~ ^(armhf|armv7|aarch64)$ ]]; then
				qbt_cross_name="${2}"
				shift 2
			else
				echo
				echo -e " ${ulrc} You must provide a valid arch option when using${cend} ${clb}-ma${cend}"
				echo
				echo -e " ${ulyc} armhf${cend}"
				echo -e " ${ulyc} armv7${cend}"
				echo -e " ${ulyc} aarch64${cend}"
				echo
				echo -e " ${ulgc} example usage:${clb} -ma aarch64${cend}"
				echo
				exit 1
			fi
			shift
			;;
		-o | --optimize)
			optimize="-march=native"
			shift
			;;
		-h-bv | --help-boost-version)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " This will let you set a specific version of boost to use with older build combos"
			echo
			echo -e " Example: ${clb}-bv 1.76.0${cend}"
			echo
			exit
			;;
		-h-o | --help-optimize)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " ${cly}Warning, using this flag will mean your static build is limited to a matching CPU${cend}"
			echo
			echo -e " Example: ${clb}-o${cend}"
			echo
			echo -e " Additonal flags used: ${clc}-march=native${cend}"
			echo
			exit
			;;
		-h-p | --help-proxy)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Specify a proxy URL and PORT to use with curl and git"
			echo
			echo -e " ${td}Example:${cend} ${td}${clb}-p${cend} ${td}${clc}username:password@https://123.456.789.321:8443${cend}"
			echo
			echo -e " ${td}${clb}-p${cend} ${td}${clc}https://proxy.com:12345${cend}"
			echo
			echo -e " ${cy}You can use this flag with this help command to see the value if called before the help option:${cend}"
			echo
			echo -e " ${td}${clb}-p${cend} ${td}${clc}https://proxy.com:12345${cend} ${td}${clb}-h-p${cend}"
			echo
			[[ -n "${qbt_curl_proxy}" ]] && echo -e " proxy command: ${clc}${qbt_curl_proxy}${tn}${cend}"
			exit
			;;
		--) # end argument parsing
			shift
			break
			;;
		*) # preserve positional arguments
			params1+=("${1}")
			shift
			;;
	esac
done
#
set -- "${params1[@]}" # Set positional arguments in their proper place.
#######################################################################################################################################################
# 2:  curl test download functions - default is no proxy - curl is a test function and curl_curl is the command function
#######################################################################################################################################################
curl_curl() {
	if [[ -z "${qbt_curl_proxy}" ]]; then
		"$(type -P curl)" -sNL4fq --connect-timeout 5 --retry 5 --retry-delay 5 --retry-max-time 25 "${@}"
	else
		"$(type -P curl)" -sNL4fq --connect-timeout 5 --retry 5 --retry-delay 5 --retry-max-time 25 --proxy-insecure -x "${qbt_curl_proxy}" "${@}"
	fi

}
#
curl() {
	if ! curl_curl "${@}"; then
		echo 'error_url'
	fi
}
#######################################################################################################################################################
# 3: git test download functions - default is no proxy - git is a test function and git_git is the command function
#######################################################################################################################################################
git_git() {
	if [[ -z "${qbt_git_proxy}" ]]; then
		"$(type -P git)" "${@}"
	else
		"$(type -P git)" -c http.sslVerify=false -c http.https://github.com.proxy="${qbt_git_proxy}" "${@}"
	fi
}
#
git() {
	if [[ "${2}" = '-t' ]]; then
		url_test="${1}"
		tag_flag="${2}"
		tag_test="${3}"
	else
		url_test="${11}" # 11th place in our download folder function
	fi
	#
	if ! curl -I "${url_test%\.git}" &> /dev/null; then
		echo
		echo -e " ${cy}There is an issue with your proxy settings or network connection${cend}"
		echo
		exit
	fi
	#
	status="$(
		git_git ls-remote --exit-code "${url_test}" "${tag_flag}" "${tag_test}" &> /dev/null
		echo "${?}"
	)"
	#
	if [[ "${tag_flag}" = '-t' && "${status}" = '0' ]]; then
		echo "${tag_test}"
	elif [[ "${tag_flag}" = '-t' && "${status}" -ge '1' ]]; then
		echo 'error_tag'
	else
		if ! git_git "${@}"; then
			echo
			echo -e " ${cy}There is an issue with your proxy settings or network connection${cend}"
			echo
			exit
		fi
	fi
}
#
test_git_ouput() {
	if [[ "${1}" = 'error_tag' ]]; then
		echo -e "${tn} ${cy}Sorry, the provided ${3} tag ${cr}$2${cend}${cy} is not valid${cend}"
	fi
}
#######################################################################################################################################################
# This function sets the build and installation directory. If the argument -b is used to set a build directory that directory is set and used.
# If nothing is specified or the switch is not used it defaults to the hard-coded path relative to the scripts location - qbittorrent-build
#######################################################################################################################################################
set_build_directory() {
	if [[ -n "${qbt_build_dir}" ]]; then
		if [[ "${qbt_build_dir}" =~ ^/ ]]; then
			qbt_install_dir="${qbt_build_dir}"
			qbt_install_dir_short="${qbt_install_dir/$HOME/\~}"
		else
			qbt_install_dir="${qbt_working_dir}/${qbt_build_dir}"
			qbt_install_dir_short="${qbt_working_dir_short}/${qbt_build_dir}"
		fi
	fi
	#
	## Set lib and include directory paths based on install path.
	include_dir="${qbt_install_dir}/include"
	lib_dir="${qbt_install_dir}/lib"
	#
	## Define some build specific variables
	LOCAL_USER_HOME="${HOME}" # Get the local user's home dir path before we contain HOME to the build dir.
	HOME="${qbt_install_dir}"
	PATH="${qbt_install_dir}/bin${PATH:+:${qbt_local_paths}}"
	PKG_CONFIG_PATH="${lib_dir}/pkgconfig"
}
#######################################################################################################################################################
# This function sets some compiler flags globally - b2 settings are set in the ~/user-config.jam  set in the installation_modules function
#######################################################################################################################################################
custom_flags_set() {
	CXXFLAGS="${optimize/*/$optimize }-std=${cxx_standard} -static -w ${qbt_strip_flags} -I${include_dir}"
	CPPFLAGS="${optimize/*/$optimize }-static -w ${qbt_strip_flags} -I${include_dir}"
	LDFLAGS="${optimize/*/$optimize }-static -L${lib_dir}"
}
#
custom_flags_reset() {
	CXXFLAGS="${optimize/*/$optimize } -w -std=${cxx_standard}"
	CPPFLAGS="${optimize/*/$optimize } -w"
	LDFLAGS=""
}
#######################################################################################################################################################
# This function is where we set your URL that we use with other functions.
#######################################################################################################################################################
set_module_urls() {
	if [[ "${what_id}" =~ ^(alpine)$ ]]; then
		libexecinfo_dev_url="${CDN_URL}/${cross_arch}/$(apk info libexecinfo-dev | awk '{print $1}' | head -n 1).apk"
		libexecinfo_static_url="${CDN_URL}/${cross_arch}/$(apk info libexecinfo-static | awk '{print $1}' | head -n 1).apk"
	fi
	#
	cmake_github_tag="$(git_git ls-remote -q -t --refs https://github.com/Kitware/CMake.git | awk '/v/{sub("refs/tags/", "");sub("(.*)(-[^0-9].*)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV | head -n 1)"
	cmake_version="${cmake_github_tag#v}"
	ninja_github_tag="$(git_git ls-remote -q -t --refs https://github.com/ninja-build/ninja.git | awk '/v/{sub("refs/tags/", "");sub("(.*)(-[^0-9].*)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV | head -n 1)"
	ninja_version="${ninja_github_tag#v}"
	#
	if [[ ! "${what_id}" =~ ^(alpine)$ ]]; then
		#bison_version="$(git_git ls-remote -q -t --refs https://git.savannah.gnu.org/git/bison.git | awk '/\/v/{sub("refs/tags/v", "");sub("(.*)((-|_)[^0-9].*)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV | head -n 1)"
		#bison_url="https://ftp.gnu.org/gnu/bison/bison-${bison_version}.tar.gz"
		bison_url="https://ftp.gnu.org/gnu/bison/$(grep -Eo 'bison-([0-9]{1,3}[.]?)([0-9]{1,3}[.]?)([0-9]{1,3}?)\.tar.gz' <(curl https://ftp.gnu.org/gnu/bison/) | sort -V | tail -1)"
	fi
	#
	if [[ ! "${what_id}" =~ ^(alpine)$ ]]; then
		#gawk_version="$(git_git ls-remote -q -t --refs https://git.savannah.gnu.org/git/gawk.git | awk '/\/tags\/gawk/{sub("refs/tags/gawk-", "");sub("(.*)(-[^0-9].*)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV | head -n 1)"
		#gawk_url="https://ftp.gnu.org/gnu/gawk/gawk-${gawk_version}.tar.gz"
		gawk_url="https://ftp.gnu.org/gnu/gawk/$(grep -Eo 'gawk-([0-9]{1,3}[.]?)([0-9]{1,3}[.]?)([0-9]{1,3}?)\.tar.gz' <(curl https://ftp.gnu.org/gnu/gawk/) | sort -V | tail -1)"
	fi
	#
	if [[ ! "${what_id}" =~ ^(alpine)$ ]]; then
		if [[ "${what_version_codename}" =~ ^(hirsute)$ ]]; then
			#glibc_version="$(git_git ls-remote -q -t --refs https://sourceware.org/git/glibc.git | awk '/\/tags\/glibc-[0-9]\.[0-9]{2}$/{sub("refs/tags/glibc-", "");sub("(.*)(-[^0-9].*)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV | head -n 1)"
			#glibc_url="https://ftp.gnu.org/gnu/libc/glibc-${glibc_version}.tar.gz"
			#glibc_url="https://ftp.gnu.org/gnu/glibc/$(grep -Eo 'glibc-([0-9]{1,3}[.]?)([0-9]{1,3}[.]?)([0-9]{1,3}?)\.tar.gz' <(curl https://ftp.gnu.org/gnu/glibc/) | sort -V | tail -1)"
			glibc_url="https://ftp.gnu.org/gnu/libc/glibc-2.33.tar.gz" # pin to the same version for this OS otherwise we get build errors
		else
			glibc_url="https://ftp.gnu.org/gnu/libc/glibc-2.31.tar.gz" # pin to the same version for this OS otherwise we get build errors
		fi
	fi
	#
	zlib_github_tag="develop" # use this to fix arm cross building with cmake until a new release including these fixes is available (>2.0.5)
	# zlib_github_version="$(git_git ls-remote -q -t --refs https://github.com/zlib-ng/zlib-ng | awk '{sub("refs/tags/", "");sub("(.*)(-[^0-9].*)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV | head -n 1)"
	zlib_version="$(curl https://raw.githubusercontent.com/zlib-ng/zlib-ng/${zlib_github_tag}/zlib.h.in | sed -rn 's|#define ZLIB_VERSION "(.*)"|\1|p')" # get the version from the headers
	zlib_github_url="https://github.com/zlib-ng/zlib-ng.git"
	#
	#zlib_github_tag="$(git_git ls-remote -q -t --refs https://github.com/madler/zlib.git | awk '{sub("refs/tags/", "");sub("(.*)(-[^0-9].*)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV | head -n 1)"
	#zlib_url="https://github.com/madler/zlib/archive/${zlib_github_tag}.tar.gz"
	#
	iconv_url="https://ftp.gnu.org/gnu/libiconv/$(grep -Eo 'libiconv-([0-9]{1,3}[.]?)([0-9]{1,3}[.]?)([0-9]{1,3}?)\.tar.gz' <(curl https://ftp.gnu.org/gnu/libiconv/) | sort -V | tail -1)"
	#
	icu_github_tag="$(git_git ls-remote -q -t --refs https://github.com/unicode-org/icu.git | awk '/\/release-/{sub("refs/tags/release-", "");sub("(.*)(-[^0-9].*)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV | head -n 1)"
	icu_url="https://github.com/unicode-org/icu/releases/download/release-${icu_github_tag}/icu4c-${icu_github_tag/-/_}-src.tgz"
	#
	openssl_github_tag="$(git_git ls-remote -q -t --refs https://github.com/openssl/openssl.git | awk '/openssl/{sub("refs/tags/", "");sub("(.*)(v6|rc|alpha|beta)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV | head -n1)"
	openssl_version="${openssl_github_tag#openssl-}"
	openssl_url="https://github.com/openssl/openssl/archive/${openssl_github_tag}.tar.gz"
	#
	boost_version="${boost_version:-$(git_git ls-remote -q -t --refs https://github.com/boostorg/boost.git | awk '{sub("refs/tags/boost-", "");sub("(.*)(rc|alpha|beta)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV | head -n1)}"
	boost_github_tag="boost-${boost_version}"
	boost_url="https://boostorg.jfrog.io/artifactory/main/release/${boost_version}/source/boost_${boost_version//./_}.tar.gz"
	boost_url_status="$(curl_curl -so /dev/null --head --write-out '%{http_code}' "https://boostorg.jfrog.io/artifactory/main/release/${boost_version}/source/boost_${boost_version//./_}.tar.gz")"
	boost_github_url="https://github.com/boostorg/boost.git"
	#
	if [[ "${qbt_qt_version}" =~ ^6\. ]]; then
		qt_github_tag_list="$(git_git ls-remote -q -t --refs https://github.com/qt/qtbase.git | awk '{sub("refs/tags/", "");sub("(.*)(-[^0-9].*)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV)"
		#
		qtbase_github_tag="$(grep -Eom1 "v${qbt_qt_version}.([0-9]{1,2})" <<< "${qt_github_tag_list}")"
		# qtbase_github_url="https://github.com/qt/qtbase.git"
		#
		qttools_github_tag="$(grep -Eom1 "v${qbt_qt_version}.([0-9]{1,2})" <<< "${qt_github_tag_list}")"
		#qttools_github_url="https://github.com/qt/qttools.git"
		#
		qtbase_url="https://download.qt.io/official_releases/qt/${qbt_qt_version}/${qtbase_github_tag/v/}/submodules/qtbase-everywhere-src-${qtbase_github_tag/v/}.tar.xz"
		qttools_url="https://download.qt.io/official_releases/qt/${qbt_qt_version}/${qttools_github_tag/v/}/submodules/qttools-everywhere-src-${qttools_github_tag/v/}.tar.xz"
		#
		qbt_qt_full_version="${qtbase_github_tag}"
	else
		qtbase_github_tag="kde/5.15"
		qtbase_github_url="https://invent.kde.org/qt/qt/qtbase.git"
		#
		qttools_github_tag="kde/5.15"
		qttools_github_url="https://invent.kde.org/qt/qt/qttools.git"
		#
		qbt_qt_full_version="$(curl "https://invent.kde.org/qt/qt/qtbase/-/raw/${qtbase_github_tag}/.qmake.conf" | sed -rn 's|MODULE_VERSION = (.*)|\1|p')" # get the version from the headers
	fi
	#
	libtorrent_github_url="https://github.com/arvidn/libtorrent.git"
	libtorrent_github_tags_list="$(git_git ls-remote -q -t --refs https://github.com/arvidn/libtorrent.git | awk '/\/v/{sub("refs/tags/", "");sub("(.*)(-[^0-9].*)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV)"
	libtorrent_github_tag_default="$(grep -Eom1 "v${libtorrent_version}.([0-9]{1,2})" <<< "${libtorrent_github_tags_list}")"
	libtorrent_github_tag="${libtorrent_github_tag:-$libtorrent_github_tag_default}"
	#
	qbittorrent_github_url="https://github.com/qbittorrent/qBittorrent.git"
	qbittorrent_github_tag_default="$(git_git ls-remote -q -t --refs https://github.com/qbittorrent/qBittorrent.git | awk '{sub("refs/tags/", "");sub("(.*)(-[^0-9].*|rc|alpha|beta)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV | head -n1)"
	qbittorrent_github_tag="${qbitorrent_github_tag:-$qbittorrent_github_tag_default}"
	#
	url_test="$(curl -so /dev/null "https://www.google.com")"
}
#######################################################################################################################################################
# This function verifies the module names from the array qbt_modules in the default values function.
#######################################################################################################################################################
installation_modules() {
	params_count="${#}"
	params_test=1
	#
	## remove modules from the delete array from the qbt_modules array
	for target in "${delete[@]}"; do
		for i in "${!qbt_modules[@]}"; do
			if [[ "${qbt_modules[i]}" = "${target}" ]]; then
				unset 'qbt_modules[i]'
			fi
		done
	done
	#
	while [[ "${params_test}" -le "${params_count}" && "${params_count}" -gt '1' ]]; do
		if [[ "${qbt_modules[*]}" =~ ${*:$params_test:1} ]]; then
			:
		else
			qbt_modules_test="fail"
		fi
		params_test="$((params_test + 1))"
	done
	#
	if [[ "${params_count}" -le '1' ]]; then
		if [[ "${qbt_modules[*]}" =~ ${*:$params_test:1} && -n "${*:$params_test:1}" ]]; then
			:
		else
			qbt_modules_test="fail"
		fi
	fi
	#
	## Activate all validated modules for installation and define some core variables.
	if [[ "${qbt_modules_test}" != 'fail' ]]; then
		if [[ "${*}" =~ ([[:space:]]|^)"all"([[:space:]]|$) ]]; then
			for module in "${qbt_modules[@]}"; do
				eval "skip_${module}=no"
			done
		else
			for module in "${@}"; do
				eval "skip_${module}=no"
			done
		fi
		#
		## Create the directories we need.
		mkdir -p "${qbt_install_dir}/logs"
		mkdir -p "${PKG_CONFIG_PATH}"
		mkdir -p "${qbt_install_dir}/completed"
		#
		## Set some python variables we need.
		python_major="$(python"${qbt_python_version}" -c "import sys; print(sys.version_info[0])")"
		python_minor="$(python"${qbt_python_version}" -c "import sys; print(sys.version_info[1])")"
		python_micro="$(python"${qbt_python_version}" -c "import sys; print(sys.version_info[2])")"
		#
		python_short_version="${python_major}.${python_minor}"
		python_link_version="${python_major}${python_minor}"
		#
		echo -e "using gcc : : : <cflags>${optimize/*/$optimize }-std=${cxx_standard} <cxxflags>${optimize/*/$optimize }-std=${cxx_standard} ;${tn}using python : ${python_short_version} : /usr/bin/python${python_short_version} : /usr/include/python${python_short_version} : /usr/lib/python${python_short_version} ;" > "$HOME/user-config.jam"
		#
		## Echo the build directory.
		echo -e "${tn} ${uyc} ${tb}Install Prefix${cend} : ${clc}${qbt_install_dir_short}${cend}"
		#
		## Some basic help
		echo -e "${tn} ${uyc} ${tb}Script help${cend} : ${clc}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${clb}-h${cend}"
	else
		echo -e "${tn} ${urc} ${tb}One or more of the provided modules are not supported${cend}"
		echo -e "${tn} ${uyc} ${tb}Below is a list of supported modules${cend}"
		echo -e "${tn} ${umc} ${clm}${qbt_modules[*]}${tn}${cend}"
		exit
	fi
}
#######################################################################################################################################################
# This function will test to see if a Jamfile patch file exists via the variable patches_github_url for the tag used.
#######################################################################################################################################################
apply_patches() {
	patch_app_name="${1}"
	# Libtorrent has two tag formats libtorrent-1_2_11 and the newer v1.2.11. Moving forward v1.2.11 is the standard format. Make sure we always get the same outcome for either
	[[ "${libtorrent_github_tag}" =~ ^RC_ ]] && libtorrent_patch_tag="${libtorrent_github_tag}"
	[[ "${libtorrent_github_tag}" =~ ^libtorrent- ]] && libtorrent_patch_tag="${libtorrent_github_tag#libtorrent-}" && libtorrent_patch_tag="${libtorrent_patch_tag//_/\.}"
	[[ "${libtorrent_github_tag}" =~ ^v[0-9] ]] && libtorrent_patch_tag="${libtorrent_github_tag#v}"
	# Start to define the default master branch we will use by transforming the libtorrent_patch_tag variable to underscores. The result is dynamic and can be: RC_1_0, RC_1_1, RC_1_2, RC_2_0 and so on.
	default_jamfile="${libtorrent_patch_tag//./\_}"
	# Remove everything after second underscore. Occasionally the tag will be short, like v2.0 so we need to make sure not remove the underscore if there is only one present.
	if [[ $(grep -o '_' <<< "$default_jamfile" | wc -l) -le 1 ]]; then
		default_jamfile="RC_${default_jamfile}"
	elif [[ $(grep -o '_' <<< "$default_jamfile" | wc -l) -ge 2 ]]; then
		default_jamfile="RC_${default_jamfile%_*}"
	fi
	#
	qbittorrent_patch_tag="${qbittorrent_github_tag#release-}" # qbittorrent has a consistent tag format of release-4.3.1.
	#
	if [[ "${patch_app_name}" == 'bootstrap-help' ]]; then # All the core variables we need for the help command are set so we can exit this function now.
		return
	fi
	#
	if [[ "${patch_app_name}" == 'bootstrap' ]]; then
		mkdir -p "${qbt_install_dir}/patches/libtorrent/${libtorrent_patch_tag}"
		mkdir -p "${qbt_install_dir}/patches/qbittorrent/${qbittorrent_patch_tag}"
		echo
		echo -e " ${cly}Using the defaults, these directories have been created:${cend}"
		echo
		echo -e " ${clc}$qbt_install_dir_short/patches/libtorrent/${libtorrent_patch_tag}${cend}"
		echo
		echo -e " ${clc}$qbt_install_dir_short/patches/qbittorrent/${qbittorrent_patch_tag}${cend}"
		echo
		echo -e " If a patch file, named ${cg}patch${cend} is found in these directories it will be applied to the relevant module with a matching tag."
	else
		patch_tag="${patch_app_name}_patch_tag"
		patch_dir="${qbt_install_dir}/patches/${patch_app_name}/${!patch_tag}"
		patch_file="${patch_dir}/patch"
		patch_file_url="https://raw.githubusercontent.com/${qbt_patches_url}/master/patches/${patch_app_name}/${!patch_tag}/patch"
		patch_jamfile="${qbt_install_dir}/libtorrent/Jamfile"
		patch_jamfile_url="https://raw.githubusercontent.com/${qbt_patches_url}/master/patches/${patch_app_name}/${!patch_tag}/Jamfile"
		#
		[[ ! -d "${patch_dir}" ]] && mkdir -p "${patch_dir}"
		#
		if [[ -f "${patch_file}" ]]; then
			echo
			echo -e " ${utick} ${cr}Using ${!patch_tag} existing patch file${cend}"
			[[ "${patch_app_name}" == 'qbittorrent' ]] && echo # purely comsetic
		else
			if curl_curl "${patch_file_url}" -o "${patch_file}"; then
				echo
				echo -e " ${utick} ${cr}Using ${!patch_tag} downloaded patch file${cend}"
				[[ "${patch_app_name}" == 'qbittorrent' ]] && echo # purely comsetic
			fi
		fi
		#
		if [[ "${patch_app_name}" == 'libtorrent' ]]; then
			if [[ -f "${patch_dir}/Jamfile" ]]; then
				cp -f "${patch_dir}/Jamfile" "${patch_jamfile}"
				echo
				echo -e " ${utick} ${cr}Using existing custom Jamfile file${cend}"
				echo
			elif curl_curl "${patch_jamfile_url}" -o "${patch_jamfile}"; then
				echo
				echo -e " ${utick} ${cr}Using downloaded custom Jamfile file${cend}"
				echo
			else
				curl_curl "https://raw.githubusercontent.com/arvidn/libtorrent/${default_jamfile}/Jamfile" -o "${patch_jamfile}"
				echo
				echo -e " ${utick} ${cr}Using libtorrent branch master Jamfile file${cend}"
				echo
			fi
		fi
		#
		[[ -f "${patch_file}" ]] && patch -p1 < "${patch_file}"
	fi
}
#######################################################################################################################################################
# This function is to test a directory exists before attemtping to cd and fail with and exit code if it doesn't.
#######################################################################################################################################################
_cd() {
	if ! cd "${1}" > /dev/null 2>&1; then
		echo -e "This directory does not exist. There is a problem"
		echo
		echo -e "${clr}${1}${cend}"
		echo
		exit 1
	fi
}
#######################################################################################################################################################
# This function is for downloading source code archives
#######################################################################################################################################################
download_file() {
	if [[ -n "${1}" ]]; then
		url_filename="${2}"
		[[ -n "${3}" ]] && subdir="/${3}" || subdir=""
		echo -e "${tn} ${uplus}${cg} Installing $1${cend}${tn}"
		file_name="${qbt_install_dir}/${1}.tar.gz"
		[[ -f "${file_name}" ]] && rm -rf {"${qbt_install_dir:?}/$(tar tf "${file_name}" | grep -Eom1 "(.*)[^/]")","${file_name}"}
		curl "${url_filename}" -o "${file_name}"
		_cmd tar xf "${file_name}" -C "${qbt_install_dir}"
		app_dir="${qbt_install_dir}/$(tar tf "${file_name}" | head -1 | cut -f1 -d"/")${subdir}"
		mkdir -p "${app_dir}"
		[[ "${1}" != 'boost' ]] && _cd "${app_dir}"
	else
		echo
		echo "You must provide a filename name for the function - download_file"
		echo "It creates the name from the appname_github_tag variable set in the URL section"
		echo
		echo "download_file filename url"
		echo
		exit
	fi
}
#######################################################################################################################################################
# This function is for downloading git releases based on their tag.
#######################################################################################################################################################
download_folder() {
	if [[ -n "${1}" ]]; then
		github_tag="${1}_github_tag"
		url_github="${2}"
		[[ -n "${3}" ]] && subdir="/${3}" || subdir=""
		echo -e "${tn} ${uplus}${cg} Installing ${1}${cend}${tn}"
		folder_name="${qbt_install_dir}/${1}"
		folder_inc="${qbt_install_dir}/include/${1}"
		[[ -d "${folder_name}" ]] && rm -rf "${folder_name}"
		[[ "${1}" == 'libtorrent' && -d "${folder_inc}" ]] && rm -rf "${folder_inc}"
		git config --global advice.detachedHead false
		_cmd git clone --no-tags --single-branch --branch "${!github_tag}" --shallow-submodules --recurse-submodules -j"$(nproc)" --depth 1 "${url_github}" "${folder_name}"
		mkdir -p "${folder_name}${subdir}"
		[[ -d "${folder_name}${subdir}" ]] && _cd "${folder_name}${subdir}"
	else
		echo
		echo "You must provide a tag name for the function - download_folder"
		echo "It creates the tag from the appname_github_tag variable set in the URL section"
		echo
		echo "download_folder tagname url subdir"
		echo
		exit
	fi
}
#######################################################################################################################################################
# This function is for removing files and folders we no longer need
#######################################################################################################################################################
delete_function() {
	if [[ -n "${1}" ]]; then
		if [[ -z "${qbt_skip_delete}" ]]; then
			[[ "$2" = 'last' ]] && echo -e "${tn} ${utick}${clr} Deleting $1 installation files and folders${cend}${tn}" || echo -e "${tn} ${utick}${clr} Deleting ${1} installation files and folders${cend}"
			#
			file_name="${qbt_install_dir}/${1}.tar.gz"
			folder_name="${qbt_install_dir}/${1}"
			[[ -f "${file_name}" ]] && rm -rf {"${qbt_install_dir:?}/$(tar tf "${file_name}" | grep -Eom1 "(.*)[^/]")","${file_name}"}
			[[ -d "${folder_name}" ]] && rm -rf "${folder_name}"
			[[ -d "${qbt_working_dir}" ]] && _cd "${qbt_working_dir}"
		else
			[[ "${2}" = 'last' ]] && echo -e "${tn} ${uyc}${clr} Skipping $1 deletion${cend}${tn}" || echo -e "${tn} ${uyc}${clr} Skipping ${1} deletion${cend}"
		fi
	else
		echo
		echo "The delete_function works in tandem with the application_name function"
		echo "Set the appname using the application_name function then use this function."
		echo
		echo "delete_function appname"
		echo
		exit
	fi
}
#######################################################################################################################################################
# This function sets the name of the application to be used with the functions download_file/folder and delete_function
#######################################################################################################################################################
application_name() {
	last_app_name="skip_${app_name}"
	app_name="${1}"
	app_name_skip="skip_${app_name}"
	app_url="${app_name}_url"
	app_github_url="${app_name}_github_url"
}
#######################################################################################################################################################
# This function skips the deletion of the -n flag is supplied
#######################################################################################################################################################
application_skip() {
	if [[ "${1}" = 'last' ]]; then
		echo -e "${tn} ${uyc} Skipping ${clm}$app_name${cend} module installation${tn}"
	else
		echo -e "${tn} ${uyc} Skipping ${clm}$app_name${cend} module installation"
	fi
}
#######################################################################################################################################################
# This function installs qt
#######################################################################################################################################################
install_qbittorrent() {
	if [[ -f "${qbt_install_dir}/completed/qbittorrent-nox" ]]; then
		#
		if [[ "$(id -un)" = 'root' ]]; then
			mkdir -p "/usr/local/bin"
			cp -rf "${qbt_install_dir}/completed/qbittorrent-nox" "/usr/local/bin"
		else
			mkdir -p "${HOME}/bin"
			cp -rf "${qbt_install_dir}/completed/qbittorrent-nox" "${LOCAL_USER_HOME}/bin"
		fi
		#
		echo -e "${tn} ${uplus} qbittorrent-nox has been installed!${cend}${tn}"
		echo -e " Run it using this command:${tn}"
		#
		[[ "$(id -un)" = 'root' ]] && echo -e " ${cg}qbittorrent-nox${cend}${tn}" || echo -e " ${cg}~/bin/qbittorrent-nox${cend}${tn}"
		#
		exit
	else
		echo -e "${tn}qbittorrent-nox has not been built to the defined install directory:${tn}"
		echo -e "${cg}${qbt_install_dir_short}/completed${cend}${tn}"
		echo -e "Please build it using the script first then install${tn}"
		#
		exit
	fi
}
#######################################################################################################################################################
# wtf is wrong now?
#######################################################################################################################################################
_cmd() {
	if ! "${@}"; then
		echo
		exit 1
	fi
}
#######################################################################################################################################################
# build command test
#######################################################################################################################################################
post_command() {
	outcome="${PIPESTATUS[0]}"
	[[ -n "${1}" ]] && command_type="${1}"
	if [[ ${outcome} -gt '0' ]]; then
		echo -e "${tn} ${urc} ${clr}Error: The ${command_type} command produced an exit code greater than 0 - Check the logs${cend}${tn}"
		exit "${outcome}"
	fi
}
#######################################################################################################################################################
# Multi Arch
#######################################################################################################################################################
_multi_arch() {
	if [[ "${qbt_cross_name}" =~ ^(armhf|armv7|aarch64)$ ]]; then
		if [[ "${what_id}" =~ ^(alpine|debian|ubuntu)$ ]]; then
			#
			[[ "${1}" != 'bootstrap' ]] && echo -e "${tn} ${ugc}${cly} Using multiarch - arch: ${qbt_cross_name} host: ${what_id} target: ${qbt_cross_target}${cend}"
			#
			case "${qbt_cross_name}" in
				armhf)
					case "${qbt_cross_target}" in
						alpine | debian | ubuntu)
							cross_arch="armel"
							qbt_cross_host="arm-linux-gnueabi"
							qbt_cross_openssl="linux-armv4"
							qbt_cross_boost="arm"
							qbt_cross_qtbase="linux-arm-gnueabi-g++"
							;;
					esac
					;;
				armv7)
					case "${qbt_cross_target}" in
						alpine)
							cross_arch="armv7"
							qbt_cross_host="armv7r-linux-musleabihf"
							qbt_cross_openssl="linux-armv4"
							qbt_cross_boost="arm"
							qbt_cross_qtbase="linux-arm-gnueabi-g++"
							;;
						debian | ubuntu)
							cross_arch="armhf"
							qbt_cross_host="arm-linux-gnueabihf"
							qbt_cross_openssl="linux-armv4"
							qbt_cross_boost="arm"
							qbt_cross_qtbase="linux-arm-gnueabi-g++"
							;;
					esac
					;;
				aarch64)
					case "${qbt_cross_target}" in
						alpine)
							cross_arch="aarch64"
							qbt_cross_host="aarch64-linux-musl"
							qbt_cross_openssl="linux-aarch64"
							qbt_cross_boost="arm"
							qbt_cross_qtbase="linux-aarch64-gnu-g++"
							;;
						debian | ubuntu)
							cross_arch="arm64"
							qbt_cross_host="aarch64-linux-gnu"
							qbt_cross_openssl="linux-aarch64"
							qbt_cross_boost="arm"
							qbt_cross_qtbase="linux-aarch64-gnu-g++"
							;;
					esac
					;;
			esac
			#
			[[ "${1}" == 'bootstrap' ]] && return
			#
			CHOST="${qbt_cross_host}"
			CC="${qbt_cross_host}-gcc"
			AR="${qbt_cross_host}-ar"
			CXX="${qbt_cross_host}-g++"
			#
			mkdir -p "${qbt_install_dir}/logs"
			#
			if [[ "${qbt_cross_target}" =~ ^(alpine)$ && ! -f "${qbt_install_dir}/${qbt_cross_host}.tar" ]]; then
				curl "https://github.com/userdocs/musl-cross-make/releases/latest/download/${qbt_cross_host}.tar.gz" > "${qbt_install_dir}/${qbt_cross_host}.tar"
				tar xf "${qbt_install_dir}/${qbt_cross_host}.tar" --strip-components=1 -C "${qbt_install_dir}"
			fi
			#
			_fix_multiarch_static_links "${qbt_cross_host}"
			#
			multi_bison=("--host=${qbt_cross_host}") # ${multi_bison[@]}
			#
			multi_gawk=("--host=${qbt_cross_host}") # ${multi_gawk[@]}
			#
			multi_glibc=("--host=${qbt_cross_host}") # ${multi_glibc[@]}
			#
			multi_iconv=("--host=${qbt_cross_host}") # ${multi_iconv[@]}
			#
			multi_icu=("--host=${qbt_cross_host}" "-with-cross-build=${qbt_install_dir}/icu/cross") # ${multi_icu[@]}
			#
			multi_openssl=("./Configure" "${qbt_cross_openssl}") # ${multi_openssl[@]}
			#
			multi_qtbase=("-xplatform" "${qbt_cross_qtbase}") # ${multi_qtbase[@]}
			#
			if [[ "${qbt_build_tool}" = 'cmake' ]]; then
				multi_libtorrent=("-D CMAKE_CXX_COMPILER=${qbt_cross_host}-g++")  # ${multi_libtorrent[@]}
				multi_qbittorrent=("-D CMAKE_CXX_COMPILER=${qbt_cross_host}-g++") # ${multi_qbittorrent[@]}
			else
				b2_toolset="gcc-arm"
				echo -e "using gcc : arm : ${qbt_cross_host}-g++ : <cflags>${optimize/*/$optimize }-std=${cxx_standard} <cxxflags>${optimize/*/$optimize }-std=${cxx_standard} ;${tn}using python : ${python_short_version} : /usr/bin/python${python_short_version} : /usr/include/python${python_short_version} : /usr/lib/python${python_short_version} ;" > "$HOME/user-config.jam"
				multi_libtorrent=("toolset=${b2_toolset}") # ${multi_libtorrent[@]}
				#
				multi_qbittorrent=("--host=${qbt_cross_host}") # ${multi_qbittorrent[@]}
			fi
			return
		else
			echo
			echo -e " ${ulrc} Multiarch only works with Alpine Linux (native or docker)${cend}"
			echo
			exit 1
		fi
	else
		multi_openssl=("./config") # ${multi_openssl[@]}
		return
	fi
	return
}
#######################################################################################################################################################
# Github Actions release info
#######################################################################################################################################################
_release_info() {
	_error_tag
	#
	echo -e "${tn} ${ugc} ${cly}Release boot-strapped${cend}"
	#
	release_info_dir="${qbt_install_dir}/release_info"
	#
	mkdir -p "${release_info_dir}"
	#
	cat > "${release_info_dir}/tag.md" <<- TAG_INFO
		${qbittorrent_github_tag#v}_${libtorrent_github_tag}
	TAG_INFO
	#
	cat > "${release_info_dir}/title.md" <<- TITLE_INFO
		qbittorrent ${qbittorrent_github_tag#release-} libtorrent ${libtorrent_github_tag#v}
	TITLE_INFO
	#
	cat > "${release_info_dir}/release.md" <<- RELEASE_INFO
		## Build info

		Qbittorrent: ${qbittorrent_github_tag#release-}
		Qt: ${qbt_qt_full_version#v}
		Libtorrent: ${libtorrent_github_tag#v}
		Boost: ${boost_version#v}
		OpenSSL: ${openssl_version}
		zlib-ng: ${zlib_version%.*}

		## Architectures and build info

		These builds were created on Alpine linux using [custom prebuilt musl toolchains](https://github.com/userdocs/musl-cross-make) for:

		|       Arch        |   Alpine Cross build files    |
		| :---------------: | :---------------------------: |
		|  armv7 aka armhf  | armv7r-linux-musleabihf-cross |
		| aarch64 aka arm64 |   aarch64-linux-musl-cross    |
		| x86_64 aka amd64  |      None - native build      |

		## Build matrix for libtorrent ${libtorrent_github_tag}

		ℹ️ qt5 is still built with qmake. qt6 will use cmake when qbittorrent adds qt6 support.

		ℹ️ [Check the build table for more info](https://github.com/userdocs/qbittorrent-nox-static#build-table---dependencies---arch---os---build-tools)

		⚠️ Binary builds are not stripped by default to preserve stacktrace / debugging features built into qBittorrent.

	RELEASE_INFO
	#
	return
}
#######################################################################################################################################################
# cmake installation
#######################################################################################################################################################
_cmake() {
	if [[ "${qbt_build_tool}" == 'cmake' ]]; then
		echo -e "${tn} ${ulbc}${clr} Checking if cmake and ninja need to be installed${cend}"
		mkdir -p "${qbt_install_dir}/bin"
		_cd "${qbt_install_dir}"
		#
		if [[ "${what_id}" =~ ^(debian|ubuntu)$ ]]; then
			if [[ "$(cmake --version 2> /dev/null | awk 'NR==1{print $3}')" != "${cmake_github_tag#v}" ]]; then
				curl "https://github.com/Kitware/CMake/releases/download/v${cmake_version}/cmake-${cmake_version}-linux-x86_64.sh" -o "${qbt_install_dir}/cmake.sh"
				if ! bash "${qbt_install_dir}/cmake.sh" --skip-license --exclude-subdir &> /dev/null; then
					post_command "cmake installation"
				fi
			fi
			#
			if [[ "$("${qbt_install_dir}/bin/ninja" --version 2> /dev/null)" != "${ninja_github_tag#v}" ]]; then
				curl "https://github.com/ninja-build/ninja/releases/download/v${ninja_version}/ninja-linux.zip" -o "${qbt_install_dir}/ninja-linux.zip"
				if unzip -q -o "${qbt_install_dir}/ninja-linux.zip" -d "${qbt_install_dir}/bin" &> /dev/null; then
					post_command "ninja installation"
				fi
				_cd "${qbt_install_dir}" && rm -f "${qbt_install_dir}/cmake.sh" "${qbt_install_dir}/ninja-linux.zip"
			fi
		fi
		#
		if [[ "${what_id}" =~ ^(alpine)$ ]]; then
			if [[ "$("${qbt_install_dir}/bin/ninja" --version 2> /dev/null)" != "${ninja_github_tag#v}" ]]; then
				download_folder ninja https://github.com/ninja-build/ninja.git
				python3 configure.py --bootstrap --host=linux
				cp -f "${qbt_install_dir}/ninja/ninja" "${qbt_install_dir}/bin/ninja"
				_cd "${qbt_install_dir}" && rm -rf "${qbt_install_dir}/ninja"
			fi
		fi
		#
		echo -e "${tn} ${ugc}${clr} cmake and ninja are installed and ready to use${cend}"
	fi
}
#######################################################################################################################################################
# static lib link fix: check for *.so and *.a versions of a lib in the $lib_dir and change the *.so link to point to the statric lib e.g. libdl.a
#######################################################################################################################################################
_fix_static_links() {
	log_name="$1"
	readarray -t library_list < <(find "${lib_dir}" -maxdepth 1 -exec bash -c 'basename "$0" ".${0##*.}"' {} \; | sort | uniq -d)
	for file in "${library_list[@]}"; do
		if [[ "$(readlink "${lib_dir}/${file}.so")" != "${file}.a" ]]; then
			ln -fsn "${file}.a" "${lib_dir}/${file}.so"
			echo "${lib_dir}${file}.so changed to point to ${file}.a" >> "${qbt_install_dir}/logs/${log_name}-fix-static-links.log.txt"
		fi
	done
	return
}
_fix_multiarch_static_links() {
	if [[ -d "${qbt_install_dir}/${qbt_cross_host}" ]]; then
		log_name="$1"
		multiarch_lib_dir="${qbt_install_dir}/${qbt_cross_host}/lib"
		readarray -t library_list < <(find "${multiarch_lib_dir}" -maxdepth 1 -exec bash -c 'basename "$0" ".${0##*.}"' {} \; | sort | uniq -d)
		for file in "${library_list[@]}"; do
			if [[ "$(readlink "${multiarch_lib_dir}/${file}.so")" != "${file}.a" ]]; then
				ln -fsn "${file}.a" "${multiarch_lib_dir}/${file}.so"
				echo "${multiarch_lib_dir}${file}.so changed to point to ${file}.a" >> "${qbt_install_dir}/logs/${log_name}-fix-static-links.log.txt"
			fi
		done
		return
	fi
}

#######################################################################################################################################################
# error functions
#######################################################################################################################################################
_error_url() {
	[[ "${url_test}" = "error_url" ]] && {
		echo
		echo -e " ${cy}There is an issue with your proxy settings or network connection${cend}"
		echo
		exit
	}
}
#
_error_tag() {
	[[ "${libtorrent_github_tag}" = "error_tag" || "${qbittorrent_github_tag}" = "error_tag" ]] && {
		echo
		exit
	}
}
#######################################################################################################################################################
# Functions part 1: Use some of our functions
#######################################################################################################################################################
set_default_values "${@}" # see functions
#
check_dependencies # see functions
#
set_build_directory # see functions
#
set_module_urls # see functions
#######################################################################################################################################################
# This section controls our flags that we can pass to the script to modify some variables and behavior.
#######################################################################################################################################################
while (("${#}")); do
	case "${1}" in
		-bs | --boot-strap)
			apply_patches bootstrap
			shift
			;;
		-bs-c | --boot-strap-cmake)
			qbt_build_tool="cmake"
			_cmake
			shift
			;;
		-bs-r | --boot-strap-release)
			_release_info
			shift
			;;
		-bs-ma | --boot-strap-multi-arch)
			if [[ -n "${2}" && "${2}" =~ ^(armhf|armv7|aarch64)$ ]]; then
				qbt_cross_name="${2}"
				shift 2
			else
				echo
				echo -e " ${ulrc} You must provide a valid arch option when using${cend} ${clb}-ma${cend}"
				echo
				echo -e " ${ulyc} armhf${cend}"
				echo -e " ${ulyc} armv7${cend}"
				echo -e " ${ulyc} aarch64${cend}"
				echo
				echo -e " ${ulgc} example usage:${clb} -ma aarch64${cend}"
				echo
				exit 1
			fi
			_multi_arch
			shift
			;;
		-bs-a | --boot-strap-all)
			apply_patches bootstrap
			_release_info
			_cmake
			_multi_arch
			shift
			;;
		-d | --debug)
			lt_debug="debug-symbols=on"
			qbt_debug="--enable-debug"
			shift
			;;
		-n | --no-delete)
			qbt_skip_delete='yes'
			shift
			;;
		-m | --master)
			libtorrent_github_tag="$(git "${libtorrent_github_url}" -t "RC_${libtorrent_version//./_}")"
			test_git_ouput "${libtorrent_github_tag}" "RC_${libtorrent_version//./_}" "libtorrent"
			#
			qbittorrent_github_tag="$(git "${qbittorrent_github_url}" -t "master")"
			test_git_ouput "${qbittorrent_github_tag}" "master" "qbittorrent"
			shift
			;;
		-lm | --libtorrent-master)
			libtorrent_github_tag="$(git "${libtorrent_github_url}" -t "RC_${libtorrent_version//./_}")"
			test_git_ouput "${libtorrent_github_tag}" "RC_${libtorrent_version//./_}" "libtorrent"
			shift
			;;
		-lt | --libtorrent-tag)
			libtorrent_github_tag="$(git "${libtorrent_github_url}" -t "$2")"
			test_git_ouput "${libtorrent_github_tag}" "$2" "libtorrent"
			shift 2
			;;
		-pr | --patch-repo)
			if [[ "$(curl "https://github.com/${2}")" != 'error_url' ]]; then
				qbt_patches_url="${2}"
			else
				echo
				echo -e " ${cy}This repo does not exist:${cend}"
				echo
				echo -e " https://github.com/${2}"
				echo
				echo -e " ${cy}Please provide a valid username and repo.${cend}"
				echo
				exit
			fi
			shift 2
			;;
		-qm | --qbittorrent-master)
			qbittorrent_github_tag="$(git "${qbittorrent_github_url}" -t "master")"
			test_git_ouput "${qbittorrent_github_tag}" "master" "qbittorrent"
			shift
			;;
		-qt | --qbittorrent-tag)
			qbittorrent_github_tag="$(git "${qbittorrent_github_url}" -t "$2")"
			test_git_ouput "${qbittorrent_github_tag}" "$2" "qbittorrent"
			shift 2
			;;
		-s | --strip)
			qbt_strip_qmake='strip'
			qbt_strip_flags='-s'
			shift
			;;
		-h | --help)
			echo
			echo -e " ${tb}${tu}Here are a list of available options${cend}"
			echo
			echo -e " ${cg}Use:${cend} ${clb}-b${cend}     ${td}or${cend} ${clb}--build-directory${cend}       ${cy}Help:${cend} ${clb}-h-b${cend}     ${td}or${cend} ${clb}--help-build-directory${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-bv${cend}    ${td}or${cend} ${clb}--boost-version${cend}         ${cy}Help:${cend} ${clb}-h-bv${cend}    ${td}or${cend} ${clb}--help-boost-version${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-c${cend}     ${td}or${cend} ${clb}--cmake${cend}                 ${cy}Help:${cend} ${clb}-h-c${cend}     ${td}or${cend} ${clb}--help-cmake${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-d${cend}     ${td}or${cend} ${clb}--debug${cend}                 ${cy}Help:${cend} ${clb}-h-d${cend}     ${td}or${cend} ${clb}--help-debug${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-bs${cend}    ${td}or${cend} ${clb}--boot-strap${cend}            ${cy}Help:${cend} ${clb}-h-bs${cend}    ${td}or${cend} ${clb}--help-boot-strap${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-bs-c${cend}  ${td}or${cend} ${clb}--boot-strap-cmake${cend}      ${cy}Help:${cend} ${clb}-h-bs-c${cend}  ${td}or${cend} ${clb}--help-boot-strap-cmake${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-bs-r${cend}  ${td}or${cend} ${clb}--boot-strap-release${cend}    ${cy}Help:${cend} ${clb}-h-bs-r${cend}  ${td}or${cend} ${clb}--help-boot-strap-release${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-bs-ma${cend} ${td}or${cend} ${clb}--boot-strap-multi-arch${cend} ${cy}Help:${cend} ${clb}-h-bs-ma${cend} ${td}or${cend} ${clb}--help-boot-strap-multi-arch${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-bs-a${cend}  ${td}or${cend} ${clb}--boot-strap-all${cend}        ${cy}Help:${cend} ${clb}-h-bs-a${cend}  ${td}or${cend} ${clb}--help-boot-strap-all${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-i${cend}     ${td}or${cend} ${clb}--icu${cend}                   ${cy}Help:${cend} ${clb}-h-i${cend}     ${td}or${cend} ${clb}--help-icu${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-lm${cend}    ${td}or${cend} ${clb}--libtorrent-master${cend}     ${cy}Help:${cend} ${clb}-h-lm${cend}    ${td}or${cend} ${clb}--help-libtorrent-master${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-lt${cend}    ${td}or${cend} ${clb}--libtorrent-tag${cend}        ${cy}Help:${cend} ${clb}-h-lt${cend}    ${td}or${cend} ${clb}--help-libtorrent-tag${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-m${cend}     ${td}or${cend} ${clb}--master${cend}                ${cy}Help:${cend} ${clb}-h-m${cend}     ${td}or${cend} ${clb}--help-master${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-ma${cend}    ${td}or${cend} ${clb}--multi-arch${cend}            ${cy}Help:${cend} ${clb}-h-ma${cend}    ${td}or${cend} ${clb}--help-multi-arch${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-n${cend}     ${td}or${cend} ${clb}--no-delete${cend}             ${cy}Help:${cend} ${clb}-h-n${cend}     ${td}or${cend} ${clb}--help-no-delete${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-o${cend}     ${td}or${cend} ${clb}--optimize${cend}              ${cy}Help:${cend} ${clb}-h-o${cend}     ${td}or${cend} ${clb}--help-optimize${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-p${cend}     ${td}or${cend} ${clb}--proxy${cend}                 ${cy}Help:${cend} ${clb}-h-p${cend}     ${td}or${cend} ${clb}--help-proxy${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-pr${cend}    ${td}or${cend} ${clb}--patch-repo${cend}            ${cy}Help:${cend} ${clb}-h-pr${cend}    ${td}or${cend} ${clb}--help-patch-repo${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-qm${cend}    ${td}or${cend} ${clb}--qbittorrent-master${cend}    ${cy}Help:${cend} ${clb}-h-qm${cend}    ${td}or${cend} ${clb}--help-qbittorrent-master${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-qt${cend}    ${td}or${cend} ${clb}--qbittorrent-tag${cend}       ${cy}Help:${cend} ${clb}-h-qt${cend}    ${td}or${cend} ${clb}--help-qbittorrent-tag${cend}"
			echo -e " ${cg}Use:${cend} ${clb}-s${cend}     ${td}or${cend} ${clb}--strip${cend}                 ${cy}Help:${cend} ${clb}-h-s${cend}     ${td}or${cend} ${clb}--help-strip${cend}"
			echo
			echo -e " ${tb}${tu}Module specific help - flags are used with the modules listed here.${cend}"
			echo
			echo -e " ${cg}Use:${cend} ${clm}all${cend} ${td}or${cend} ${clm}module-name${cend}          ${cg}Usage:${cend} ${clc}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${clm}all${cend} ${clb}-i${cend}"
			echo
			echo -e " ${td}${clm}all${cend}         ${td}-${cend} ${td}${cly}optional${cend} ${td}Recommended method to install all modules${cend}"
			echo -e " ${td}${clm}install${cend}     ${td}-${cend} ${td}${cly}optional${cend} ${td}Install the ${td}${clc}${qbt_install_dir_short}/completed/qbittorrent-nox${cend} ${td}binary${cend}"
			[[ "${what_id}" =~ ^(alpine)$ ]] && echo -e "${td} ${clm}libexecinfo${cend} ${td}-${cend} ${td}${clr}required${cend} ${td}Build libexecinfo${cend}"
			[[ "${what_id}" =~ ^(debian|ubuntu)$ ]] && echo -e "${td} ${clm}bison${cend}       ${td}-${cend} ${td}${clr}required${cend} ${td}Build bison${cend}"
			[[ "${what_id}" =~ ^(debian|ubuntu)$ ]] && echo -e " ${td}${clm}gawk${cend}        ${td}-${cend} ${td}${clr}required${cend} ${td}Build gawk${cend}"
			[[ "${what_id}" =~ ^(debian|ubuntu)$ ]] && echo -e " ${td}${clm}glibc${cend}       ${td}-${cend} ${td}${clr}required${cend} ${td}Build libc locally to statically link nss${cend}"
			echo -e " ${td}${clm}zlib${cend}        ${td}-${cend} ${td}${clr}required${cend} ${td}Build zlib locally${cend}"
			echo -e " ${td}${clm}iconv${cend}       ${td}-${cend} ${td}${clr}required${cend} ${td}Build iconv locally${cend}"
			echo -e " ${td}${clm}icu${cend}         ${td}-${cend} ${td}${cly}optional${cend} ${td}Build ICU locally${cend}"
			echo -e " ${td}${clm}openssl${cend}     ${td}-${cend} ${td}${clr}required${cend} ${td}Build openssl locally${cend}"
			echo -e " ${td}${clm}boost${cend}       ${td}-${cend} ${td}${clr}required${cend} ${td}Download, extract and build the boost library files${cend}"
			echo -e " ${td}${clm}libtorrent${cend}  ${td}-${cend} ${td}${clr}required${cend} ${td}Build libtorrent locally${cend}"
			echo -e " ${td}${clm}qtbase${cend}      ${td}-${cend} ${td}${clr}required${cend} ${td}Build qtbase locally${cend}"
			echo -e " ${td}${clm}qttools${cend}     ${td}-${cend} ${td}${clr}required${cend} ${td}Build qttools locally${cend}"
			echo -e " ${td}${clm}qbittorrent${cend} ${td}-${cend} ${td}${clr}required${cend} ${td}Build qbittorrent locally${cend}"
			echo
			exit
			;;
		-h-b | --help-build-directory)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Default build location: ${cc}${qbt_install_dir_short}${cend}"
			echo
			echo -e " ${clb}-b${cend} or ${clb}--build-directory${cend} to set the location of the build directory."
			echo
			echo -e " ${cy}Paths are relative to the script location. I recommend that you use a full path.${cend}"
			echo
			echo -e " ${td}Example:${cend} ${td}${cg}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${td}${clm}all${cend} ${td}- Will install all modules and build libtorrent to the default build location${cend}"
			echo
			echo -e " ${td}Example:${cend} ${td}${cg}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${td}${clm}all ${clb}-b${cend} ${td}${clc}\"\$HOME/build\"${cend} ${td}- Will specify a build directory and install all modules to that custom location${cend}"
			echo
			echo -e " ${td}Example:${cend} ${td}${cg}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${td}${clm}module${cend} ${td}- Will install a single module to the default build location${cend}"
			echo
			echo -e " ${td}Example:${cend} ${td}${cg}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${td}${clm}module${cend} ${clb}-b${cend} ${td}${clc}\"\$HOME/build\"${cend} ${td}- will specify a custom build directory and install a specific module use to that custom location${cend}"
			#
			echo
			exit
			;;
		-h-bs | --help-boot-strap)
			apply_patches bootstrap-help
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Creates dirs in this structure: ${cc}${qbt_install_dir_short}/patches/APPNAME/TAG/patch${cend}"
			echo
			echo -e " Add your patches there, for example."
			echo
			echo -e " ${cc}${qbt_install_dir_short}/patches/libtorrent/${libtorrent_patch_tag}/patch${cend}"
			echo
			echo -e " ${cc}${qbt_install_dir_short}/patches/qbittorrent/${qbittorrent_patch_tag}/patch${cend}"
			echo
			exit
			;;
		-h-bs-c | --help-boot-cmake)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " This bootstrap will install cmake and ninja build to the build directory"

			echo
			echo -e "${clg} Usage:${cend} ${clc}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${clb}-bs-c${cend}"
			echo
			exit
			;;
		-h-bs-r | --help-boot-strap-release)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e "${clr} Github action specific. You probably dont need it${cend}"
			echo
			echo -e " This switch creates some github release template files in this directory"
			echo
			echo -e " ${qbt_install_dir_short}/release_info"
			echo
			echo -e "${clg} Usage:${cend} ${clc}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${clb}-bs-r${cend}"
			echo
			exit
			;;
		-h-bs-ma | --help-boot-strap-multi-arch)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " ${urc}${clr} Github action and ALpine specific. You probably dont need it${cend}"
			echo
			echo -e " This switch bootstraps the musl cross build files needed for any provided and supported architecture"
			echo
			echo -e " ${uyc} armhf"
			echo -e " ${uyc} armv7"
			echo -e " ${uyc} aarch64"
			echo
			echo -e "${clg} Usage:${cend} ${clc}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${clb}-bs-ma ${qbt_cross_name:-aarch64}${cend}"
			echo
			echo -e " ${uyc} You can also set it as a variable to trigger cross building: ${clb}export qbt_cross_name=${qbt_cross_name:-aarch64}${cend}"
			echo
			exit
			;;
		-h-bs-a | --help-boot-strap-all)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " ${urc}${clr} Github action specific and Apine only. You probably dont need it${cend}"
			echo
			echo -e " Performs all bootstrapping options"
			echo
			echo -e "${clg} Usage:${cend} ${clc}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${clb}-bs-a${cend}"
			echo
			echo -e " ${uyc} ${cly}Patches${cend}"
			echo -e " ${uyc} ${cly}Release info${cend}"
			echo -e " ${uyc} ${cly}Cmake and ninja build${cend} if the ${clb}-c${cend} flag is passed"
			echo -e " ${uyc} ${cly}Multi arch${cend} if the ${clb}-ma${cend} flag is passed"
			echo
			echo -e " Equivalent of doing: ${clc}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${clb}-bs -bs-r${cend}"
			echo
			echo -e " And with ${clb}-c${cend} and ${clb}-ma${cend} : ${clc}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${clb}-bs -bs-c -bs-ma -bs-r ${cend}"
			echo
			exit
			;;
		-h-c | --help-cmake)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " This flag can change the build process in a few ways."
			echo
			echo -e " ${uyc} Use cmake to build libtorrent."
			echo -e " ${uyc} Use cmake to build qbittorrent."
			echo
			echo -e " ${uyc} You can use this flag with ICU and qtbase will use ICU instead of iconv."
			echo
			exit
			;;
		-h-d | --help-debug)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Enables debug symbols for libtorrent and qbitorrent when building"
			echo
			exit
			;;
		-h-n | --help-no-delete)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Skip all delete functions for selected modules to leave source code directories behind."
			echo
			echo -e " ${td}This flag is provided with no arguments.${cend}"
			echo
			echo -e " ${clb}-n${cend}"
			echo
			exit
			;;
		-h-i | --help-icu)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Use ICU libraries when building qBittorrent. Final binary size will be around ~50Mb"
			echo
			echo -e " ${td}This flag is provided with no arguments.${cend}"
			echo
			echo -e " ${clb}-i${cend}"
			echo
			exit
			;;
		-h-m | --help-master)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Always use the master branch for ${cg}libtorrent RC_${libtorrent_version//./_}${cend}"
			echo
			echo -e " Always use the master branch for ${cg}qBittorrent ${qbittorrent_github_tag/release-/}${cend}"
			echo
			echo -e " ${td}This flag is provided with no arguments.${cend}"
			echo
			echo -e " ${clb}-lm${cend}"
			echo
			exit
			;;
		-h-ma | --help-multi-arch)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " ${urc}${clr} Github action and ALpine specific. You probably dont need it${cend}"
			echo
			echo -e " This switch will make the script use the cross build configuration for these supported architectures"
			echo
			echo -e " ${uyc} armhf"
			echo -e " ${uyc} armv7"
			echo -e " ${uyc} aarch64"
			echo
			echo -e "${clg} Usage:${cend} ${clc}${qbt_working_dir_short}/$(basename -- "$0")${cend} ${clb}-bs-ma ${qbt_cross_name:-aarch64}${cend}"
			echo
			echo -e " ${uyc} You can also set it as a variable to trigger cross building: ${clb}export qbt_cross_name=${qbt_cross_name:-aarch64}${cend}"
			echo
			exit
			;;
		-h-lm | --help-libtorrent-master)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Always use the master branch for ${cg}libtorrent-$libtorrent_version${cend}"
			echo
			echo -e " This master that will be used is: ${cg}RC_${libtorrent_version//./_}${cend}"
			echo
			echo -e " ${td}This flag is provided with no arguments.${cend}"
			echo
			echo -e " ${clb}-lm${cend}"
			echo
			exit
			;;
		-h-lt | --help-libtorrent-tag)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Use a provided libtorrent tag when cloning from github."
			echo
			echo -e " ${cy}You can use this flag with this help command to see the value if called before the help option.${cend}"
			echo
			echo -e " ${cg}${qbt_working_dir_short}/$(basename -- "$0")${cend}${clb} -lt ${clc}${libtorrent_github_tag}${cend} ${clb}-h-lt${cend}"
			if [[ ! "${libtorrent_github_tag}" =~ (error_tag|error_22) ]]; then
				echo
				echo -e " ${td}This is tag that will be used is: ${cg}${libtorrent_github_tag}${cend}"
			fi
			echo
			echo -e " ${td}This flag must be provided with arguments.${cend}"
			echo
			echo -e " ${clb}-lt${cend} ${clc}${libtorrent_github_tag}${cend}"
			echo
			exit
			;;
		-h-pr | --help-patch-repo)
			apply_patches bootstrap-help
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Specify a username and repo to use patches hosted on github${cend}"
			echo
			echo -e " ${cg}Example:${cend} ${clb}-pr${cend} ${clc}usnerame/repo${cend}"
			echo
			echo -e " ${cy}There is a specific github directory format you need to use with this flag${cend}"
			echo
			echo -e " ${clc}patches/libtorrent/$libtorrent_patch_tag/patch${cend}"
			echo -e " ${clc}patches/libtorrent/$libtorrent_patch_tag/Jamfile${cend} ${clr}(defaults to branch master)${cend}"
			echo
			echo -e " ${clc}patches/qbittorrent/$qbittorrent_patch_tag/patch${cend}"
			echo
			echo -e " ${cy}If an installation tag matches a hosted tag patch file, it will be automaticlaly used.${cend}"
			echo
			echo -e " The tag name will alway be an abbreviated version of the default or specificed tag.${cend}"
			echo
			exit
			;;
		-h-qm | --help-qbittorrent-master)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Always use the master branch for ${cg}qBittorrent${cend}"
			echo
			echo -e " This master that will be used is: ${cg}master${cend}"
			echo
			echo -e " ${td}This flag is provided with no arguments.${cend}"
			echo
			echo -e " ${clb}-qm${cend}"
			echo
			exit
			;;
		-h-qt | --help-qbittorrent-tag)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Use a provided qBittorrent tag when cloning from github."
			echo
			echo -e " ${cy}You can use this flag with this help command to see the value if called before the help option.${cend}"
			echo
			echo -e " ${cg}${qbt_working_dir_short}/$(basename -- "$0")${cend}${clb} -qt ${clc}${qbittorrent_github_tag}${cend} ${clb}-h-qt${cend}"
			#
			if [[ ! "${qbittorrent_github_tag}" =~ (error_tag|error_22) ]]; then
				echo
				echo -e " ${td}This tag that will be used is: ${cg}${qbittorrent_github_tag}${cend}"
			fi
			echo
			echo -e " ${td}This flag must be provided with arguments.${cend}"
			echo
			echo -e " ${clb}-qt${cend} ${clc}${qbittorrent_github_tag}${cend}"
			echo
			exit
			;;
		-h-s | --help-strip)
			echo
			echo -e " ${ulcc} ${tb}${tu}Here is the help description for this flag:${cend}"
			echo
			echo -e " Strip the qbittorrent-nox binary of unneeded symbols to decrease file size"
			echo
			echo -e " ${uyc} This will reduce the size of the file by about 15MB but break the built in stacktrace features of qbittorrent"
			echo
			echo -e " ${td}This flag is provided with no arguments.${cend}"
			echo
			echo -e " ${clb}-s${cend}"
			echo
			exit
			;;
		--) # end argument parsing
			shift
			break
			;;
		-*) # unsupported flags
			echo -e "${tn}Error: Unsupported flag ${cr}$1${cend} - use ${cg}-h${cend} or ${cg}--help${cend} to see the valid options${tn}" >&2
			exit 1
			;;
		*) # preserve positional arguments
			params2+=("${1}")
			shift
			;;
	esac
done
#
set -- "${params2[@]}" # Set positional arguments in their proper place.
#######################################################################################################################################################
# Functions part 2: Use some of our functions
#######################################################################################################################################################
[[ "${*}" =~ ([[:space:]]|^)"install"([[:space:]]|$) ]] && install_qbittorrent "${@}" # see functions
#######################################################################################################################################################
# Lets dip out now if we find that any github tags failed validation or the urls are invalid
#######################################################################################################################################################
_error_url
#
_error_tag
#######################################################################################################################################################
# Functions part 3: Use some of our functions
#######################################################################################################################################################
installation_modules "${@}" # see functions
#
_cmake
#
_multi_arch
#######################################################################################################################################################
# libexecinfo installation
#######################################################################################################################################################
application_name libexecinfo
#
if [[ "${!app_name_skip:-yes}" = 'no' ]] || [[ "${1}" = "${app_name}" ]]; then
	echo -e "${tn} ${uplus}${cg} Installing ${app_name}${cend}"
	#
	curl "${libexecinfo_dev_url}" -o "${qbt_install_dir}/libexecinfo_dev_${cross_arch}.apk"
	curl "${libexecinfo_static_url}" -o "${qbt_install_dir}/libexecinfo_static_${cross_arch}.apk"
	#
	tar xf "${qbt_install_dir}/libexecinfo_dev_${cross_arch}.apk" --strip-components=1 -C "${qbt_install_dir}"
	tar xf "${qbt_install_dir}/libexecinfo_static_${cross_arch}.apk" --strip-components=1 -C "${qbt_install_dir}"
	#
	_fix_static_links "${app_name}"
else
	application_skip
fi
#######################################################################################################################################################
# bison installation
#######################################################################################################################################################
application_name bison
#
if [[ "${!app_name_skip:-yes}" = 'no' || "${1}" = "${app_name}" ]]; then
	custom_flags_set
	download_file "${app_name}" "${!app_url}"
	#
	./configure "${multi_bison[@]}" --prefix="${qbt_install_dir}" |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
	make -j"$(nproc)" CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	post_command build
	#
	make install |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	delete_function "${app_name}"
else
	application_skip
fi
#######################################################################################################################################################
# gawk installation
#######################################################################################################################################################
application_name gawk
#
if [[ "${!app_name_skip:-yes}" = 'no' || "$1" = "${app_name}" ]]; then
	custom_flags_set
	download_file "${app_name}" "${!app_url}"
	#
	./configure "${multi_gawk[@]}" --prefix="$qbt_install_dir" |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
	make -j"$(nproc)" CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	post_command build
	#
	make install |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	_fix_static_links "${app_name}"
	#
	delete_function "${app_name}"
else
	application_skip
fi
#######################################################################################################################################################
# glibc installation
#######################################################################################################################################################
application_name glibc
#
if [[ "${!app_name_skip:-yes}" = 'no' || "${1}" = "${app_name}" ]]; then
	custom_flags_reset
	download_file "${app_name}" "${!app_url}"
	#
	mkdir -p build
	_cd "${app_dir}/build"
	#
	"${app_dir}/configure" "${multi_glibc[@]}" --prefix="${qbt_install_dir}" --enable-static-nss --disable-nscd |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
	make -j"$(nproc)" |& tee -a "${qbt_install_dir}/logs/$app_name.log.txt"
	#
	post_command build
	#
	make install |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	_fix_static_links "${app_name}"
	#
	delete_function "${app_name}"
else
	application_skip
fi
#######################################################################################################################################################
# zlib installation
#######################################################################################################################################################
application_name zlib
#
if [[ "${!app_name_skip:-yes}" = 'no' || "${1}" = "${app_name}" ]]; then
	custom_flags_set
	download_folder "${app_name}" "${!app_github_url}"
	#
	if [[ "${qbt_build_tool}" == 'cmake' ]]; then
		mkdir -p "${qbt_install_dir}/graphs/${zlib_version}"
		cmake -Wno-dev -Wno-deprecated --graphviz="${qbt_install_dir}/graphs/${zlib_version}/dep-graph.dot" -G Ninja -B build \
			-D CMAKE_VERBOSE_MAKEFILE="${qbt_cmake_debug:-OFF}" \
			-D CMAKE_CXX_STANDARD="${standard}" \
			-D CMAKE_PREFIX_PATH="${qbt_install_dir}" \
			-D BUILD_SHARED_LIBS=OFF \
			-D ZLIB_COMPAT=ON \
			-D CMAKE_INSTALL_PREFIX="${qbt_install_dir}" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		cmake --build build |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		#
		post_command build
		#
		cmake --install build |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		#
		dot -Tpng -o "${qbt_install_dir}/completed/${app_name}-graph.png" "${qbt_install_dir}/graphs/${zlib_version}/dep-graph.dot"
		#
	else
		./configure --prefix="${qbt_install_dir}" --static --zlib-compat |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
		make -j"$(nproc)" CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		#
		post_command build
		#
		make install |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	fi
	#
	_fix_static_links "${app_name}"
	#
	delete_function "${app_name}"
else
	application_skip
fi
#######################################################################################################################################################
# iconv installation
#######################################################################################################################################################
application_name iconv
#
if [[ "${!app_name_skip:-yes}" = 'no' || "${1}" = "${app_name}" ]]; then
	custom_flags_reset
	download_file "${app_name}" "${!app_url}"
	#
	./configure "${multi_iconv[@]}" --prefix="${qbt_install_dir}" --disable-shared --enable-static CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	make -j"$(nproc)" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	make install |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	_fix_static_links "${app_name}"
	#
	post_command build
	#
	delete_function "${app_name}"
else
	application_skip
fi
#######################################################################################################################################################
# ICU installation
#######################################################################################################################################################
application_name icu
#
if [[ "${!app_name_skip:-yes}" = 'no' || "${1}" = "${app_name}" ]]; then
	custom_flags_reset
	download_file "${app_name}" "${!app_url}" "/source"
	#
	if [[ "${qbt_cross_name}" =~ ^(armhf|armv7|aarch64)$ ]]; then
		mkdir -p "${qbt_install_dir}/${app_name}/cross"
		_cd "${qbt_install_dir}/${app_name}/cross"
		"${qbt_install_dir}/${app_name}/source/runConfigureICU" Linux/gcc
		make -j"$(nproc)"
		_cd "${qbt_install_dir}/${app_name}/source"
	fi
	#
	./configure "${multi_icu[@]}" --prefix="${qbt_install_dir}" --disable-shared --enable-static --disable-samples --disable-tests --with-data-packaging=static CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	make -j"$(nproc)" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	post_command build
	#
	make install |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	_fix_static_links "${app_name}"
	#
	delete_function "${app_name}"
else
	application_skip
fi
#######################################################################################################################################################
# openssl installation
#######################################################################################################################################################
application_name openssl
#
if [[ "${!app_name_skip:-yes}" = 'no' || "${1}" = "${app_name}" ]]; then
	custom_flags_set
	download_file "${app_name}" "${!app_url}"
	#
	"${multi_openssl[@]}" --prefix="${qbt_install_dir}" --libdir="${lib_dir}" --openssldir="/etc/ssl" threads no-shared no-dso no-comp CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
	make -j"$(nproc)" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	post_command build
	#
	make install_sw |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	#
	_fix_static_links "${app_name}"
	#
	delete_function "${app_name}"
else
	application_skip
fi
#######################################################################################################################################################
# boost libraries install
#######################################################################################################################################################
application_name boost
#
if [[ "${!app_name_skip:-yes}" = 'no' ]] || [[ "${1}" = "${app_name}" ]]; then
	custom_flags_set
	#
	[[ -d "${qbt_install_dir}/boost" ]] && delete_function "${app_name}"
	#
	if [[ "${boost_url_status}" =~ (200) ]]; then
		download_file "${app_name}" "${boost_url}"
		mv -f "${qbt_install_dir}/boost_${boost_version//./_}/" "${qbt_install_dir}/boost"
		_cd "${qbt_install_dir}/boost"
	fi
	#
	if [[ "${boost_url_status}" =~ (403|404) ]]; then
		download_folder "${app_name}" "${!app_github_url}"
	fi
	#
	if [[ "${qbt_build_tool}" != 'cmake' ]]; then
		"${qbt_install_dir}/boost/bootstrap.sh" |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
		ln -s "${qbt_install_dir}/boost/boost" "${qbt_install_dir}/boost/include"
	else
		echo -e " ${uyc} Skipping b2 as we are using cmake"
	fi
	#
	if [[ "${boost_url_status}" =~ (403|404) ]]; then
		"${qbt_install_dir}/boost/b2" headers |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
	fi
else
	application_skip
fi
#######################################################################################################################################################
# libtorrent installation
#######################################################################################################################################################
application_name libtorrent
#
if [[ "${!app_name_skip:-yes}" = 'no' ]] || [[ "${1}" = "${app_name}" ]]; then
	if [[ ! -d "${qbt_install_dir}/boost" ]]; then
		echo -e "${tn} ${urc} ${clr}Warning${cend} This module depends on the boost module. Use them together: ${clm}boost libtorrent${cend}"
	else
		custom_flags_set
		download_folder "${app_name}" "${!app_github_url}"
		#
		apply_patches "${app_name}"
		#
		BOOST_ROOT="${qbt_install_dir}/boost"
		BOOST_INCLUDEDIR="${qbt_install_dir}/boost"
		BOOST_BUILD_PATH="${qbt_install_dir}/boost"
		#
		if [[ "${qbt_build_tool}" == 'cmake' ]]; then
			mkdir -p "${qbt_install_dir}/graphs/${libtorrent_github_tag}"
			cmake -Wno-dev -Wno-deprecated --graphviz="${qbt_install_dir}/graphs/${libtorrent_github_tag}/dep-graph.dot" -G Ninja -B build \
				"${multi_libtorrent[@]}" \
				-D CMAKE_VERBOSE_MAKEFILE="${qbt_cmake_debug:-OFF}" \
				-D CMAKE_BUILD_TYPE="Release" \
				-D CMAKE_CXX_STANDARD="${standard}" \
				-D CMAKE_PREFIX_PATH="${qbt_install_dir};${qbt_install_dir}/boost" \
				-D Boost_NO_BOOST_CMAKE=TRUE \
				-D CMAKE_CXX_FLAGS="${CXXFLAGS}" \
				-D BUILD_SHARED_LIBS=OFF \
				-D Iconv_LIBRARY="${lib_dir}/libiconv.a" \
				-D CMAKE_INSTALL_PREFIX="${qbt_install_dir}" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
			cmake --build build |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
			#
			post_command build
			#
			cmake --install build |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
			#
			dot -Tpng -o "${qbt_install_dir}/completed/${app_name}-graph.png" "${qbt_install_dir}/graphs/${libtorrent_github_tag}/dep-graph.dot"
			#
		else
			[[ ${qbt_cross_name} =~ ^(armhf|armv7)$ ]] && arm_libatomic="-l:libatomic.a"
			#
			if [[ "${libtorrent_github_tag}" =~ ^(RC_1_1|libtorrent-1_1_.*) ]]; then
				libtorrent_library_filename="libtorrent.a"
			else
				libtorrent_library_filename="libtorrent-rasterbar.a"
			fi
			#
			if [[ "${libtorrent_github_tag}" =~ ^(RC_2|v2\.0\..*) ]]; then
				lt_version_options=()
				libtorrent_libs="-l:libboost_system.a -l:${libtorrent_library_filename} -l:libtry_signal.a ${arm_libatomic}"
				lt_cmake_flags="-DTORRENT_USE_LIBCRYPTO -DTORRENT_USE_OPENSSL -DTORRENT_USE_I2P=1 -DBOOST_ALL_NO_LIB -DBOOST_ASIO_ENABLE_CANCELIO -DBOOST_ASIO_HAS_STD_CHRONO -DBOOST_MULTI_INDEX_DISABLE_SERIALIZATION -DBOOST_SYSTEM_NO_DEPRECATED -DBOOST_SYSTEM_STATIC_LINK=1 -DTORRENT_SSL_PEERS -DBOOST_ASIO_NO_DEPRECATED"
			else
				lt_version_options=("iconv=on")
				libtorrent_libs="-l:libboost_system.a -l:${libtorrent_library_filename} ${arm_libatomic} -l:libiconv.a"
				lt_cmake_flags="-DTORRENT_USE_LIBCRYPTO -DTORRENT_USE_OPENSSL -DTORRENT_USE_I2P=1 -DBOOST_ALL_NO_LIB -DBOOST_ASIO_ENABLE_CANCELIO -DBOOST_ASIO_HAS_STD_CHRONO -DBOOST_MULTI_INDEX_DISABLE_SERIALIZATION -DBOOST_SYSTEM_NO_DEPRECATED -DBOOST_SYSTEM_STATIC_LINK=1 -DTORRENT_USE_ICONV=1"
			fi
			#
			"${qbt_install_dir}/boost/b2" "${multi_libtorrent[@]}" -j"$(nproc)" "${lt_version_options[@]}" address-model="$(getconf LONG_BIT)" "${lt_debug}" optimization=speed cxxstd="${standard}" dht=on encryption=on crypto=openssl i2p=on extensions=on variant=release threading=multi link=static boost-link=static cxxflags="${CXXFLAGS}" cflags="${CPPFLAGS}" linkflags="${LDFLAGS}" install --prefix="${qbt_install_dir}" |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
			#
			post_command build
			#
			libtorrent_strings_version="$(strings -d "${lib_dir}/${libtorrent_library_filename}" | grep -Eom1 "^libtorrent/[0-9]\.(.*)")" # ${libtorrent_strings_version#*/}
			#
			cat > "${PKG_CONFIG_PATH}/libtorrent-rasterbar.pc" <<- LIBTORRENT_PKG_CONFIG
				prefix=${qbt_install_dir}
				libdir=\${prefix}/lib
				includedir=\${prefix}/include

				Name: libtorrent-rasterbar
				Description: The libtorrent-rasterbar libraries
				Version: ${libtorrent_strings_version#*/}

				Requires:
				Libs: -L\${libdir} ${libtorrent_libs}
				Cflags: -I\${includedir} -I${BOOST_ROOT} ${lt_cmake_flags}
			LIBTORRENT_PKG_CONFIG
		fi
		#
		_fix_static_links "${app_name}"
		#
		delete_function "${app_name}"
	fi
else
	application_skip
fi
#######################################################################################################################################################
# qtbase installation
#######################################################################################################################################################
application_name qtbase
#
if [[ "${!app_name_skip:-yes}" = 'no' ]] || [[ "${1}" = "${app_name}" ]]; then
	custom_flags_set
	#
	if [[ "${qbt_qt_version}" =~ ^6\. ]]; then
		download_file "${app_name}" "${!app_url}"
	else
		download_folder "${app_name}" "${!app_github_url}"
	fi
	#
	case "${qbt_cross_name}" in
		armhf | armv7)
			sed "s|arm-linux-gnueabi|${qbt_cross_host}|g" -i "mkspecs/linux-arm-gnueabi-g++/qmake.conf"
			;;
		aarch64)
			sed "s|aarch64-linux-gnu|${qbt_cross_host}|g" -i "mkspecs/linux-aarch64-gnu-g++/qmake.conf"
			;;
	esac
	#
	if [[ "${what_id}" =~ ^(alpine)$ ]]; then
		libexecinfo="${lib_dir}/libexecinfo.a"
	fi
	#
	if [[ "${qbt_build_tool}" == 'cmake' && "${qbt_qt_version}" =~ ^6\. ]]; then
		mkdir -p "${qbt_install_dir}/graphs/${libtorrent_github_tag}"
		cmake -Wno-dev -Wno-deprecated --graphviz="${qbt_install_dir}/graphs/${qbt_qt_full_version}/dep-graph.dot" -G Ninja -B build \
			"${multi_libtorrent[@]}" \
			-D CMAKE_VERBOSE_MAKEFILE="${qbt_cmake_debug:-OFF}" \
			-D CMAKE_BUILD_TYPE="release" \
			-D QT_FEATURE_optimize_full=on -D QT_FEATURE_static=on -D QT_FEATURE_shared=off \
			-D QT_FEATURE_gui=off -D QT_FEATURE_openssl_linked=on \
			-D QT_FEATURE_dbus=off -D QT_FEATURE_system_pcre2=off -D QT_FEATURE_widgets=off \
			-D QT_FEATURE_testlib=off -D QT_BUILD_EXAMPLES=off -D QT_BUILD_TESTS=off \
			-D CMAKE_CXX_STANDARD="${standard}" \
			-D CMAKE_PREFIX_PATH="${qbt_install_dir}" \
			-D CMAKE_CXX_FLAGS="${CXXFLAGS}" \
			-D BUILD_SHARED_LIBS=OFF \
			-D CMAKE_CXX_STANDARD_LIBRARIES="${libexecinfo}" \
			-D CMAKE_SKIP_RPATH=on -D CMAKE_SKIP_INSTALL_RPATH=on \
			-D CMAKE_INSTALL_PREFIX="${qbt_install_dir}" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		cmake --build build |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		#
		post_command build
		#
		cmake --install build |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		#
		dot -Tpng -o "${qbt_install_dir}/completed/${app_name}-graph.png" "${qbt_install_dir}/graphs/${qbt_qt_full_version}/dep-graph.dot"
	elif [[ "${qbt_qt_version}" =~ ^(5\.[0-9]{1,2})$ ]]; then
		if [[ "${qbt_skip_icu}" = 'no' ]]; then
			icu=("-icu" "-no-iconv" "QMAKE_CXXFLAGS=-w -fpermissive")
		else
			icu=("-no-icu" "-iconv" "QMAKE_CXXFLAGS=-w -fpermissive")
		fi
		#
		# If Alpine, add the QMAKE_LIBS_EXECINFO path so we can build qtbase with no errors whilst linking against libexecinfo
		[[ "${what_id}" =~ ^(alpine)$ ]] && echo "QMAKE_LIBS_EXECINFO     = ${lib_dir}/libexecinfo.a" >> "mkspecs/common/linux.conf"
		#
		# Don't strip by default by disabling these options. We will set it as off by default and use it with a switch
		echo "CONFIG                 += ${qbt_strip_qmake:-nostrip}" >> "mkspecs/common/linux.conf"
		#
		./configure "${multi_qtbase[@]}" -prefix "${qbt_install_dir}" "${icu[@]}" -opensource -confirm-license -release \
			-openssl-linked -static -c++std "${cxx_standard}" -qt-pcre \
			-no-feature-glib -no-feature-opengl -no-feature-dbus -no-feature-gui -no-feature-widgets -no-feature-testlib -no-compile-examples \
			-skip tests -nomake tests -skip examples -nomake examples \
			-I "${include_dir}" -L "${lib_dir}" QMAKE_LFLAGS="${LDFLAGS}" |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
		make -j"$(nproc)" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		#
		post_command build
		#
		make install |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	else
		echo -e "${tn} ${urc} Please use a correct qt and build tool combination${tn}"
		echo -e " ${urc} ${utick} qt5 + qmake ${utick} qt6 + cmake ${ucross} qt5 + cmake ${ucross} qt6 + qmake${tn}"
		exit 1
	fi
	#
	_fix_static_links "${app_name}"
	#
	delete_function "${app_name}"
else
	application_skip
fi
#######################################################################################################################################################
# qttools installation
#######################################################################################################################################################
application_name qttools
#
if [[ "${!app_name_skip:-yes}" = 'no' ]] || [[ "${1}" = "${app_name}" ]]; then
	custom_flags_set
	#
	if [[ "${qbt_qt_version}" =~ ^6\. ]]; then
		download_file "${app_name}" "${!app_url}"
	else
		download_folder "${app_name}" "${!app_github_url}"
	fi
	#
	if [[ "${what_id}" =~ ^(alpine)$ ]]; then
		libexecinfo="${lib_dir}/libexecinfo.a"
	fi
	#
	if [[ "${qbt_build_tool}" == 'cmake' && "${qbt_qt_version}" =~ ^6\. ]]; then
		mkdir -p "${qbt_install_dir}/graphs/${libtorrent_github_tag}"
		cmake -Wno-dev -Wno-deprecated --graphviz="${qbt_install_dir}/graphs/${qbt_qt_full_version}/dep-graph.dot" -G Ninja -B build \
			"${multi_libtorrent[@]}" \
			-D CMAKE_VERBOSE_MAKEFILE="${qbt_cmake_debug:-OFF}" \
			-D CMAKE_BUILD_TYPE="release" \
			-D CMAKE_CXX_STANDARD="${standard}" \
			-D CMAKE_PREFIX_PATH="${qbt_install_dir}" \
			-D CMAKE_CXX_FLAGS="${CXXFLAGS}" \
			-D BUILD_SHARED_LIBS=OFF \
			-D CMAKE_CXX_STANDARD_LIBRARIES="${libexecinfo}" \
			-D CMAKE_SKIP_RPATH=on -D CMAKE_SKIP_INSTALL_RPATH=on \
			-D CMAKE_INSTALL_PREFIX="${qbt_install_dir}" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		cmake --build build |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		#
		post_command build
		#
		cmake --install build |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		#
		dot -Tpng -o "${qbt_install_dir}/completed/${app_name}-graph.png" "${qbt_install_dir}/graphs/${qbt_qt_full_version}/dep-graph.dot"
	elif [[ "${qbt_qt_version}" =~ ^(5\.[0-9]{1,2})$ ]]; then
		"${qbt_install_dir}/bin/qmake" -set prefix "${qbt_install_dir}" |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
		#
		"${qbt_install_dir}/bin/qmake" QMAKE_CXXFLAGS="-std=${cxx_standard} -static -w -fpermissive" QMAKE_LFLAGS="-static" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		make -j"$(nproc)" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		#
		post_command build
		#
		make install |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
	else
		echo -e "${tn} ${urc} Please use a correct qt and build tool combination${tn}"
		echo -e " ${urc} ${utick} qt5 + qmake ${utick} qt6 + cmake ${ucross} qt5 + cmake ${ucross} qt6 + qmake"
		exit 1
	fi
	_fix_static_links "${app_name}"
	#
	delete_function "${app_name}"
else
	application_skip
fi
#######################################################################################################################################################
# qBittorrent installation
#######################################################################################################################################################
application_name qbittorrent
#
if [[ "${!app_name_skip:-yes}" = 'no' ]] || [[ "${1}" = "${app_name}" ]]; then
	if [[ ! -d "${qbt_install_dir}/boost" ]]; then
		echo -e "${tn} ${urc} ${clr}Warning${cend} This module depends on the boost module. Use them together: ${clm}boost qbittorrent${cend}"
		echo
	else
		custom_flags_set
		#
		download_folder "${app_name}" "${!app_github_url}"
		#
		apply_patches "${app_name}"
		#
		if [[ "${what_id}" =~ ^(alpine)$ ]]; then
			libexecinfo="${lib_dir}/libexecinfo.a"
		fi
		#
		if [[ "${qbt_build_tool}" == 'cmake' ]]; then
			mkdir -p "${qbt_install_dir}/graphs/${qbittorrent_github_tag}"
			cmake -Wno-dev -Wno-deprecated --graphviz="${qbt_install_dir}/graphs/${qbittorrent_github_tag}/dep-graph.dot" -G Ninja -B build \
				"${multi_qbittorrent[@]}" \
				-D CMAKE_VERBOSE_MAKEFILE="${qbt_cmake_debug:-OFF}" \
				-D CMAKE_BUILD_TYPE="release" \
				-D QT6="${qbt_use_qt6}" \
				-D CMAKE_CXX_STANDARD="${standard}" \
				-D CMAKE_PREFIX_PATH="${qbt_install_dir};${qbt_install_dir}/boost" \
				-D Boost_NO_BOOST_CMAKE=TRUE \
				-D CMAKE_CXX_FLAGS="${CXXFLAGS}" \
				-D Iconv_LIBRARY="${lib_dir}/libiconv.a" \
				-D CMAKE_CXX_STANDARD_LIBRARIES="${libexecinfo}" \
				-D GUI=OFF \
				-D CMAKE_INSTALL_PREFIX="${qbt_install_dir}" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
			cmake --build build |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
			#
			post_command build
			#
			cmake --install build |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
			#
			dot -Tpng -o "${qbt_install_dir}/completed/${app_name}-graph.png" "${qbt_install_dir}/graphs/${qbittorrent_github_tag}/dep-graph.dot"
		else
			./bootstrap.sh |& tee "${qbt_install_dir}/logs/${app_name}.log.txt"
			./configure \
				QT_QMAKE="${qbt_install_dir}/bin" \
				--prefix="${qbt_install_dir}" \
				"${multi_qbittorrent[@]}" \
				"${qbt_debug}" \
				--disable-gui \
				CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
				--with-boost="${qbt_install_dir}/boost" --with-boost-libdir="${lib_dir}" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
			make -j"$(nproc)" |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
			#
			post_command build
			#
			make install |& tee -a "${qbt_install_dir}/logs/${app_name}.log.txt"
		fi
		#
		[[ -f "${qbt_install_dir}/bin/qbittorrent-nox" ]] && cp -f "${qbt_install_dir}/bin/qbittorrent-nox" "${qbt_install_dir}/completed/qbittorrent-nox"
		#
		delete_function boost
		delete_function "${app_name}" last
	fi
else
	application_skip last
fi
#######################################################################################################################################################
# We are all done so now exit
#######################################################################################################################################################
exit
