$HOSTNAME = ""
params.outdir = 'results'  


if (!params.Token){params.Token = ""} 
if (!params.Profile){params.Profile = ""} 
if (!params.ObjectID){params.ObjectID = ""} 

Channel.value(params.Token).set{g_1_Value_g_0}
Channel.value(params.Profile).set{g_2_Value_g_0}
Channel.value(params.ObjectID).set{g_3_Value_g_0}


process Header {

publishDir params.outdir, overwrite: true, mode: 'copy',
	saveAs: {filename ->
	if (filename =~ /.*header.txt$/) "HeaderOutput/$filename"
	else if (filename =~ /logs\/.*log$/) "Logs/$filename"
}

input:
 val accesstoken from g_1_Value_g_0
 val storageprofile from g_2_Value_g_0
 val objectid from g_3_Value_g_0

output:
 file "*header.txt"  into g_0_txtFile
 file "logs/*log"  into g_0_logFile

container = 'shub://thakk/Score-client'
// Pull from singularity hub
tag "$objectid"

// We need some environment variables inside singularity container, so lets bash them
"""
bash -c 'export ACCESSTOKEN=${accesstoken} ; export STORAGE_PROFILE=${storageprofile} ; java -Xmx3G --illegal-access=deny -Dlogging.path=/tmp -Dspring.config.additional-location=/usr/local/score-client/conf/ -Dlogging.config=/usr/local/score-client/conf/logback.xml -cp /usr/local/score-client/lib/score-client.jar org.springframework.boot.loader.JarLauncher view --header-only --object-id ${objectid}' > ${objectid}_header.txt
mkdir logs
cp /tmp/client.log logs/${objectid}_score-client.log
"""
}


workflow.onComplete {
println "##Pipeline execution summary##"
println "---------------------------"
println "##Completed at: $workflow.complete"
println "##Duration: ${workflow.duration}"
println "##Success: ${workflow.success ? 'OK' : 'failed' }"
println "##Exit status: ${workflow.exitStatus}"
}
