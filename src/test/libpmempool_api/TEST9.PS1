#
# Copyright 2016, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#
#     * Neither the name of the copyright holder nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# libpmempool_api/TEST9 -- test for checking API
#
[CmdletBinding(PositionalBinding=$false)]
Param(
    [alias("d")]
    $DIR = ""
    )
$Env:UNITTEST_NAME = "libpmempool_api\TEST9"
$Env:UNITTEST_NUM = "9"

. ..\unittest\unittest.ps1

require_fs_type any

setup

$POOL="$DIR\file.pool"
$LOG="out${Env:UNITTEST_NUM}.log"
$LOG_TEMP="out${Env:UNITTEST_NUM}_part.log"

rm $LOG -Force -Recurse -ea si
rm $LOG_TEMP -Force -Recurse -ea si

$pool_args=@{"blk"="blk 512"; "log"="log"}

foreach ($h in $pool_args.GetEnumerator()) {
	echo "Pool type: $($h.Name) Params: $($h.Value)" >> $LOG_TEMP
	expect_normal_exit "$PMEMPOOL$Env:EXESUFFIX create $($h.Value) $POOL" >> $LOG_TEMP
	&$PMEMSPOIL $POOL "pool_hdr.major=7" >> $LOG_TEMP
	check_file $POOL

	cp $POOL ${POOL}_copy >> $LOG_TEMP
	expect_normal_exit $Env:EXE_DIR\libpmempool_test$Env:EXESUFFIX $POOL `
		-d 1 -r 1 -y 1 -t $($h.Name)
	cat $LOG >> $LOG_TEMP
	cmp $POOL ${POOL}_copy >> $LOG_TEMP

	rm $POOL -Force -Recurse -ea si
	rm ${POOL}_copy -Force -Recurse -ea si
}
rm $LOG -Force
mv $LOG_TEMP $LOG

check
pass
