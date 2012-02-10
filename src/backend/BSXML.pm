#
# Copyright (c) 2006, 2007 Michael Schroeder, Novell Inc.
# Copyright (c) 2008 Adrian Schroeter, Novell Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program (see the file COPYING); if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
#
################################################################
#
# XML templates for the BuildService. See XML/Structured.
#

package BSXML;

use strict;

# 
# an explained example entry of this file
#
#our $pack = [             creates <package name="" project=""> space
#    'package' =>          
#	'name',
#	'project',
#	[],                before the [] all strings become attributes to <package>
#       'title',           from here on all strings become children like <title> </title>
#       'description',
#       [[ 'person' =>     creates <person> children, the [[ ]] syntax allows any number of them including zero
#           'role',        again role and userid attributes, both are required
#           'userid',    
#       ]],                this block describes a <person role="defeatist" userid="statler" /> construct
# 	@flags,            copies in the block of possible flag definitions
#       [ $repo ],         refers to the repository construct and allows again any number of them (0-X)
#];                        closes the <package> child with </package>

our $repo = [
   'repository' => 
	'name',
	'rebuild',
	'block',
	'linkedbuild',
     [[ 'releasetarget' =>
	    'project',
	    'repository',
	    'trigger',
     ]],
     [[ 'path' =>
	    'project',
	    'repository',
     ]],
      [ 'arch' ],
	'status',
];

our @disableenable = (
     [[	'disable' =>
	'arch',
	'repository',
     ]],
     [[	'enable' =>
	'arch',
	'repository',
     ]],
);

our @flags = (
      [ 'lock' => @disableenable ],
      [ 'build' => @disableenable ],
      [ 'publish' => @disableenable ],
      [ 'debuginfo' => @disableenable ],
      [ 'useforbuild' => @disableenable ],
      [ 'binarydownload' => @disableenable ],
      [ 'sourceaccess' => @disableenable ],
      [ 'access' => @disableenable ],
);

our $download = [
    'download' =>
    'baseurl',
    'metafile',
    'mtype',
    'arch',
];

our $maintenance = [
    'maintenance' =>
     [[ 'maintains' =>
            'project',
     ]],
];

our $proj = [
    'project' =>
        'name',
        'kind',
	 [],
        'title',
        'description',
     [[	'link' =>
	    'project',
     ]],
	'remoteurl',
	'remoteproject',
	'mountproject',
      [ 'devel', =>
	    'project',
      ],
     [[ 'person' =>
            'role',
            'userid',
     ]],
     [[ 'group' =>
            'role',
            'groupid',
     ]],
      [ $download ],
	$maintenance,
      [ 'attributes' => 
         [[ 'namespace' => 
		'name', 
	     [[ 'modifiable_by' =>
		    'user',
		    'group',
		    'role',
             ]],
         ]],
         [[ 'definition' => 
		'name', 
		'namespace', 
		[],
		'count',
              [ 'default' =>
		  [ 'value' ],
              ],
              [ 'allowed' =>
		  [ 'value' ],
              ],
             [[ 'modifiable_by' =>
		    'user',
		    'group',
		    'role',
             ]],
         ]],
      ],
	@flags,
      [ $repo ],
];

our $pack = [
    'package' =>
	'name',
	'project',
	[],
        'title',
        'description',
      [ 'devel', =>
	    'project',
	    'package',
      ],
     [[ 'person' =>
            'role',
            'userid',
     ]],
     [[ 'group' =>
            'role',
            'groupid',
     ]],
	@disableenable,
	@flags,
	'url',
	'bcntsynctag',
];

our $packinfo = [
    'info' =>
	'repository',
	'name',
	'file',
	'error',
	  [ 'dep' ],
	  [ 'prereq' ],
	  [ 'imagetype' ],
	  [ 'imagearch' ],
	 [[ 'path' =>
		'project',
		'repository',
	]],
	 [[ 'extrasource' =>
		'project',
		'package',
		'srcmd5',
		'file',
	 ]],
];

our $linked = [
    'linked' =>
	'project',
	'package',
];

our $aggregatelist = [
    'aggregatelist' =>
     [[ 'aggregate' =>
	    'project',
	    [],
            'nosources',
	  [ 'package' ],
	  [ 'binary' ],
	 [[ 'repository' =>
		'target',
		'source',
         ]],
     ]],
];

# former: kernel - 123 - 1   123: incident
# now:    sec-123 - 1 -1
our $patchinfo = [
    'patchinfo' => 
            'incident', # optional, gets replaced on with updateinfoid on release
            'version',	# optional, defaults to 1
            [],
	  [ 'package' ],# optional
	  [ 'binary' ],	# optional
         [[ 'issue' =>
		'tracker',
		'id',
		'_content',
	 ]],
            'category',
            'rating',
            'summary',
            'description',
            'swampid',	# obsolete
            'packager',
            'zypp_restart_needed',
            'reboot_needed',
            'relogin_needed',
];

our $projpack = [
    'projpack' =>
    'repoid',
     [[ 'project' =>
	    'name',
	    'kind',
	     [],
	    'title',
	    'description',
	    'config',
	    'patternmd5',
	 [[ 'link' =>
		'project',
	 ]],
	    'remoteurl',
	    'remoteproject',
	    @flags,
	  [ $repo ],
          [ $download ],
	 [[ 'package' =>
		'name',
		'rev',
		'srcmd5',	# commit id
		'versrel',
		'verifymd5',	# tree id
		'originproject',
		'revtime',
		[ $linked ],
		'error',
		[ $packinfo ],
		$aggregatelist,
		$patchinfo,
		@flags,
		'bcntsynctag',
	 ]],
     ]],
     [[ 'remotemap' =>
	    'project',
	    'root',
	    'remoteurl', 
	    'remoteproject', 
	    'remoteroot', 
	    'proto',	# project data not included
	     [],
	    'config',
	  [ $repo ],
	    'error',
     ]],
];

our $linkinfo = [
    'linkinfo' =>
	# information from link
	'project',
	'package',
	'rev',
	'srcmd5',
	'baserev',
	'missingok',
	# expanded / unexpanded srcmd5
	'xsrcmd5',
	'lsrcmd5',
	'error',
	'lastworking',
      [ $linked ],
];

our $serviceinfo = [
    'serviceinfo' =>
	# information in case a source service is part of package
	'code',         # can be "running", "failed", "succeeded"
	'xsrcmd5',
	'lsrcmd5',
        [],
	'error',        # contains error message (with new lines) in case of error
];

our $dir = [
    'directory' =>
	'name',
	'count',	# obsolete, the API sets this for some requests
	'rev',
	'vrev',
	'srcmd5',
        'tproject',     # obsolete, use linkinfo
        'tpackage',     # obsolete, use linkinfo
        'trev',         # obsolete, use linkinfo
        'tsrcmd5',      # obsolete, use linkinfo
        'lsrcmd5',      # obsolete, use linkinfo
        'error',
        'xsrcmd5',      # obsolete, use linkinfo
        $linkinfo,
        $serviceinfo,
     [[ 'entry' =>
	    'name',
	    'md5',
	    'size',
	    'mtime',
	    'error',
	    'id',
     ]]
];

our $fileinfo = [
    'fileinfo' =>
	'filename',
	[],
	'name',
        'epoch',
	'version',
	'release',
	'arch',
	'summary',
	'description',
	'size',
	'mtime',
      [ 'provides' ],
      [ 'requires' ],
      [ 'prerequires' ],
      [ 'conflicts' ],
      [ 'obsoletes' ],
      [ 'recommends' ],
      [ 'supplements' ],
      [ 'suggests' ],
      [ 'enhances' ],

     [[ 'provides_ext' =>
	    'dep',
	 [[ 'requiredby' =>
		'name',
		'epoch',
		'version',
		'release',
		'arch',
		'project',
		'repository',
	 ]],
     ]],
     [[ 'requires_ext' =>
	    'dep',
	 [[ 'providedby' =>
		'name',
		'epoch',
		'version',
		'release',
		'arch',
		'project',
		'repository',
	 ]],
     ]],
];

our $sourceinfo = [
    'sourceinfo' =>
	'package',
	'rev',
	'vrev',
	'srcmd5',
	'lsrcmd5',
	'verifymd5',
	[],
	'filename',
	'error',
	'originproject',
       [ $linked ],

	'name',
	'version',
	'release',
       [ 'subpacks' ],
       [ 'deps' ],
       [ 'prereqs' ],
       [ 'exclarch' ],
       [ 'badarch' ],
];

our $sourceinfolist = [
    'sourceinfolist' =>
      [ $sourceinfo ],
];

our $buildinfo = [
    'buildinfo' =>
	'project',
	'repository',
	'package',
	'srcserver',
	'reposerver',
	'downloadurl',
	[],
	'job',
	'arch',
	'hostarch',     # for cross build
	'error',
	'srcmd5',
	'verifymd5',
	'rev',
	'reason',       # just for the explain string of a build reason
	'needed',       # number of blocked
	'revtime',	# time of last commit
	'readytime',
	'specfile',	# obsolete
	'file',
	'versrel',
	'bcnt',
	'release',
	'debuginfo',
      [ 'subpack' ],
      [ 'imagetype' ],
      [ 'dep' ],
     [[ 'bdep' =>
	'name',
	'preinstall',
	'vminstall',
	'cbpreinstall',
	'cbinstall',
	'sb2install',
	'runscripts',
	'notmeta',
	'noinstall',

	'epoch',
	'version',
	'release',
	'arch',
	'project',
	'repository',
	'repoarch',
	'package',
	'srcmd5',
     ]],
      [ 'pdep' ],	# obsolete
     [[ 'path' =>
	    'project',
	    'repository',
	    'server',
     ]],
     [[ 'syspath' =>
	    'project',
	    'repository',
	    'server',
     ]],
];

our $jobstatus = [
    'jobstatus' =>
	'code',
	'result',       # succeeded, failed or unchanged
	'details',
	[],
	'starttime',
	'endtime',
	'workerid',
	'hostarch',

	'uri',		# uri to reach worker

	'arch',		# our architecture
	'job',		# our jobname
	'jobid',	# md5 of job info file
];

our $buildreason = [
    'reason' =>
       [],
       'explain',             # Readable reason
       'time',                # unix time from start build
       'oldsource',           # last build source md5 sum, if a source change was the reason
       [[ 'packagechange' =>  # list changed files which are used for building
          'change',           # kind of change (content/meta change, additional file or removed file)
          'key',              # file name
       ]],
];

our $buildstatus = [
    'status' =>
	'package',
	'code',
	'status',	# obsolete, now code
	'error',	# obsolete, now details
	[],
	'details',

	'workerid',	# last build data
	'hostarch',
	'readytime',
	'starttime',
	'endtime',

	'job',		# internal, job when building

	'uri',		# obsolete
	'arch',		# obsolete
];

our $builddepinfo = [
    'builddepinfo' =>
     [[ 'package' =>
	    'name',
	    [],
	    'source',
	  [ 'pkgdep' ],
	  [ 'subpkg' ],
     ]],
     [[ 'cycle' =>
	  [ 'package' ],
     ]],
];

our $event = [
    'event' =>
	'type',
	[],
	'project',
	'repository',
	'arch',
	'package',
	'job',
	'due',
];

our $events = [
    'events' =>
	'next',
	'sync',
       [ $event ],
];

our $revision = [
     'revision' =>
	'rev',
	'vrev',
	[],
	'srcmd5',
	'version',
	'time',
	'user',
	'comment',
	'requestid',
];

our $revisionlist = [
    'revisionlist' =>
      [ $revision ]
];

our $buildhist = [
    'buildhistory' =>
     [[ 'entry' =>
	    'rev',
	    'srcmd5',
	    'versrel',
	    'bcnt',
	    'time',
     ]],
];

our $binaryversionlist = [
    'binaryversionlist' =>
     [[ 'binary' =>
	    'name',
	    'sizek',
	    'error',
	    'hdrmd5',
	    'metamd5',
	    'leadsigmd5',
     ]],
];

our $packagebinaryversionlist = [
    'packagebinaryversionlist' =>
     [[ 'binaryversionlist' =>
            'package',
         [[ 'binary' =>
		'name',
		'sizek',
		'error',
		'hdrmd5',
		'metamd5',
		'leadsigmd5',
	 ]],
     ]],
];

our $worker = [
    'worker' =>
	'hostarch',
	'ip',
	'port',
	'workerid',
      [ 'buildarch' ],
	'memory',	# in MBytes
	'disk',		# in MBytes
	'tellnojob',

	'job',		# set when worker is busy
	'arch',		# set when worker is busy
];

our $packstatuslist = [
    'packstatuslist' =>
	'project',
	'repository',
	'arch',
     [[ 'packstatus' =>
	    'name',
	    'status',
	    'error',
     ]],
     [[ 'packstatussummary' =>
	    'status',
	    'count',
     ]],
];

our $linkpatch = [
    '' =>
      [ 'add' =>
	    'name',
	    'type',
	    'after',
	    'popt',
	    'dir',
      ],
      [ 'apply' =>
	    'name',
      ],
      [ 'delete' =>
	    'name',
      ],
        'branch',
        'topadd',
];

our $link = [
    'link' =>
	'project',
	'package',
	'rev',
	'cicount',
	'baserev',
	'missingok',
      [ 'patches' =>
	  [ $linkpatch ],
      ],
];

our $workerstatus = [
    'workerstatus' =>
	'clients',
     [[ 'idle' =>
	    'uri',
	    'workerid',
	    'hostarch',
     ]], 
     [[ 'building' =>
	    'uri',
	    'workerid',
	    'hostarch',
	    'project',
	    'repository',
	    'package',
	    'arch',
	    'starttime',
     ]],
     [[ 'waiting', =>
	    'arch',
	    'jobs',
     ]],
     [[ 'blocked', =>
	    'arch',
	    'jobs',
     ]],
     [[ 'buildavg', =>
            'arch',
	    'buildavg',
     ]],
     [[ 'scheduler' =>
	    'arch',
	    'state',
	    'starttime',
	  [ 'queue' =>
		'high',
		'med',
		'low',
		'next',
	  ],
     ]],
];

our $workerstate = [
    'workerstate' =>
	'state',
	'jobid',
];

our $jobhistlay = [
	'package',
	'rev',
	'srcmd5',
	'versrel',
	'bcnt',
	'readytime',
	'starttime',
	'endtime',
	'code',
	'uri',
	'workerid',
	'hostarch',
	'reason',
];

our $jobhist = [
    'jobhist' =>
	@$jobhistlay,
];

our $jobhistlist = [
    'jobhistlist' =>
      [ $jobhist ],
];

our $ajaxstatus = [
    'ajaxstatus' =>
     [[ 'watcher' =>
	    'filename',
	    'state',
	 [[ 'job' =>
		'id',
		'ev',
		'fd',
		'peer',
		'request',
	 ]],
     ]],
     [[ 'rpc' =>
	    'uri',
	    'state',
	    'ev',
	    'fd',
	 [[ 'job' =>
		'id',
		'ev',
		'fd',
		'peer',
		'starttime',
		'request',
	 ]],
     ]],
     [[ 'serialize' =>
	    'filename',
	 [[ 'job' =>
		'id',
		'ev',
		'fd',
		'peer',
		'request',
	 ]],
     ]],
];

our $serverstatus = [
    'serverstatus' =>
     [[ 'job' =>
	    'id',
	    'starttime',
	    'pid',
	    'peer',
	    'request',
     ]],
];

##################### new api stuff

our $binarylist = [
    'binarylist' =>
	'package',
     [[ 'binary' =>
	    'filename',
	    'size',
	    'mtime',
     ]],
];

our $summary = [
    'summary' =>
     [[ 'statuscount' =>
	    'code',
	    'count',
     ]],
];

our $result = [
    'result' =>
	'project',
	'repository',
	'arch',
	'code',	# pra state, can be "unknown", "broken", "scheduling", "blocked", "building", "finished", "publishing", "published" or "unpublished"
	'state', # old name of 'code', to be removed
	'details',
	'dirty', # marked for re-scheduling if element exists, state might not be correct anymore
      [ $buildstatus ],
      [ $binarylist ],
        $summary,
];

our $resultlist = [
    'resultlist' =>
	'state',
	'retryafter',
      [ $result ],
];

our $opstatus = [
    'status' =>
	'code',
	'origin',
	[],
	'summary',
	'details',
     [[ 'data' =>
	    'name',
	    '_content',
     ]],
      [ 'exception' =>
	    'type',
	    'message',
	  [ 'backtrace' =>
	      [ 'line' ],
	  ],
      ],
];

my $rpm_entry = [
    'rpm:entry' =>
        'kind',
        'name',
        'epoch',
        'ver',
        'rel',
        'flags',
];

our $pattern = [
    'pattern' =>
	'xmlns',      # obsolete, moved to patterns
	'xmlns:rpm',  # obsolete, moved to patterns
	[],
	'name',
    'arch',
     [[ 'version' =>
        'epoch',
        'ver',
        'rel',
     ]],
     [[ 'summary' =>
	    'lang',
	    '_content',
     ]],
     [[ 'description' =>
	    'lang',
	    '_content',
     ]],
	'default',
	'uservisible',
     [[ 'category' =>
	    'lang',
	    '_content',
     ]],
	'icon',
	'script',
      [ 'rpm:provides' => [ $rpm_entry ], ],
      [ 'rpm:conflicts' => [ $rpm_entry ], ],
      [ 'rpm:obsoletes' => [ $rpm_entry ], ],
      [ 'rpm:requires' => [ $rpm_entry ], ],
      [ 'rpm:suggests' => [ $rpm_entry ], ],
      [ 'rpm:enhances' => [ $rpm_entry ], ],
      [ 'rpm:supplements' => [ $rpm_entry ], ],
      [ 'rpm:recommends' => [ $rpm_entry ], ],
];

our $patterns = [
    'patterns' =>
	'count',
	'xmlns',
	'xmlns:rpm',
	[],
      [ $pattern ],
];

our $ymp = [
    'metapackage' =>
        'xmlns:os',
        'xmlns',
        [],
     [[ 'group' =>
	    'recommended',
	    'distversion',
	    [],
	    'name',
	    'summary',
	    'description',
	    'remainSubscribed',
	  [ 'repositories' =>
	     [[ 'repository' =>
		    'recommended',
		    'format',
		    'producturi',
		    [],
		    'name',
		    'summary',
		    'description',
		    'url',
	     ]],
	    ],
	  [ 'software' =>
	     [[ 'item' =>
		    'type',
		    'recommended',
		    'architectures',
		    'action',
		    [],
		    'name',
		    'summary',
		    'description',
	     ]],
	  ],
      ]],
];

our $binary_id = [
    'binary' => 
	'name',
	'project',
	'package',
	'repository',
	'version',
	'release',
	'arch',
	'filename',
	'filepath',
	'baseproject',
	'type',
];

our $pattern_id = [
    'pattern' => 
	'name',
	'project',
	'repository',
	'arch',
	'filename',
	'filepath',
	'baseproject',
	'type',
];

our $request = [
    'request' =>
	'id',
	'type',		# obsolete, still here to handle OBS pre-1.5 requests
	'key',		# cache key, not really in request
	'retryafter',	# timed out waiting for a key change
     [[ 'action' =>
	    'type',	# currently submit, delete, change_devel, add_role, maintenance_release, maintenance_incident, set_bugowner
	  [ 'source' =>
	        'project',
	        'package',
	        'rev',        # belongs to package attribute
	        'repository', # for merge request
	  ],
	  [ 'target' =>
		'project',
		'package',
	        'repository', # for merge request
	  ],
	  [ 'person' =>
		'name',
		'role',
	  ],
	  [ 'group' =>
		'name',
		'role',
	  ],
          [ 'options' =>
		[],
		'sourceupdate', # can be cleanup, update or noupdate
		'updatelink',   # can be true or false
          ],
	  [ 'acceptinfo' =>
	        'rev',
	        'srcmd5',
	        'osrcmd5',
	        'xsrcmd5',
	        'oxsrcmd5',
          ],
     ]],
      [ 'submit' =>          # this is old style, obsolete by request, but still supported
	  [ 'source' =>
		'project',
		'package',
		'rev',
	  ],
	  [ 'target' =>
		'project',
		'package',
	  ],
      ],
      [ 'state' =>
	    'name',
	    'who',
	    'when',
	    'superseded_by', # set when state.name is "superseded"
	    [],
	    'comment',
      ],
     [[ 'review' =>
            'state',         # review state (new/accepted or declined)
            'by_user',       # this user shall review it
            'by_group',      # one of this groupd shall review it
                             # either user or group must be used, never both
            'by_project',    # any maintainer of this project can review it
            'by_package',    # any maintainer of this package can review it (requires by_project)
            'who',           # this user has reviewed it
	    'when',
	    [],
	    'comment',
     ]],
     [[ 'history' =>
	    'name',
	    'who',
	    'when',
	    'superseded_by',
	    [],
	    'comment',
     ]],
	'title',
	'description',
];

our $repositorystate = [
    'repositorystate' => 
      [ 'blocked' ],
];

our $collection = [
    'collection' => 
	'matches',
	'limited',
      [ $request ],
      [ $proj ],
      [ $pack ],
      [ $binary_id ],
      [ $pattern_id ],
      [ 'value' ],
];

our $quota = [
    'quota' =>
	'packages',
     [[ 'project' =>
	    'name',
	    'packages',
     ]],
];

our $schedulerinfo = [
  'schedulerinfo' =>
	'arch',
	'started',
	'time',
	[],
	'slept',
	'notready',
      [ 'queue' =>
	    'high',
	    'med',
	    'low',
	    'next',
      ],
	'projects',
	'repositories',
     [[ 'worst' =>
	    'project',
	    'repository',
	    'packages',
	    'time',
     ]],
        'buildavg',
	'avg',
	'variance',
];

our $person = [
  'person' =>
	'login',
	'email',
	'realname',
	[ 'globalrole' ],
	[ 'watchlist' =>
		[[ 'project' =>
			'name',
		]],
	],
];

our $comps = [
    'comps' =>
    [[ 'group' =>
	[],
	'id',
	[[ 'description' =>
	    'xml:lang',
	    '_content',
	]],
	[[ 'name' =>
	    'xml:lang',
	    '_content',
	]],
	[ 'packagelist' =>
	    [[ 'packagereq' =>
		'type',
		'_content',
	    ]],
	],
    ]],
];

our $dispatchprios = [
    'dispatchprios' =>
     [[ 'prio' =>
	    'project',
	    'repository',
	    'arch',
	    'adjust',
     ]],
];

# list of used services for a package or project
our $services = [
    'services' =>
    [[ 'service' =>
       'name',
       'mode', # "localonly" is skipping this service on server side, "trylocal" is trying to merge changes directly in local files, "disabled" is just skipping it
       [],
       [[ 'param' => 'name', '_content' ]],
    ]],
];

# service type definitions
our $servicetype = [
    'service' =>
        'name',
        'hidden', # "true" to suppress it from service list in GUIs
        [],
        'summary',
        'description',
        [[ 'parameter' =>
                     'name',
                     [],
                     'description',
                     'required', # don't run without this parameter
                     'allowmultiple', # This parameter can be used multiple times
                     [[ 'allowedvalue' => '_content' ]], # list of possible values
        ]],
];
our $servicelist = [
    'servicelist' =>
        [ $servicetype ],
];

our $updateinfoitem = [
     'update' =>
	    'from',
	    'status',
	    'type',
	    'version',
	    [],
	    'id',
	    'title',
	    'severity',
	    'release',
	  [ 'issued' =>
		'date',
	  ],
	  [ 'updated' =>
		'date',
	  ],
	    'reboot_suggested',
	  [ 'references' =>
	     [[ 'reference' =>
		    'href',
		    'id',
		    'title',
		    'type',
	     ]],
	  ],
	    'description',
	  [ 'pkglist',
	     [[	'collection' =>
		    'short',
		    [],
		    'name',
		 [[ 'package' =>
			'name',
			'epoch',
			'version',
			'release',
			'arch',
			'src',
			[],
			'filename',
		      [ 'sum' =>	# obsolete?
			    'type',
			    '_content',
		      ],
			'reboot_suggested',
			'restart_suggested',
			'relogin_suggested',
		 ]],
	     ]],
	  ],
];

our $updateinfo = [
    'updates' =>
      [ $updateinfoitem ],
];

our $deltapackage = [
    'newpackage' =>
	'name',
	'epoch',
	'version',
	'release',
	'arch',
     [[ 'delta' =>
	    'oldepoch',
	    'oldversion',
	    'oldrelease',
	    [],
	    'filename',
	    'sequence',
	    'size',
	  [ 'checksum' =>
		'type',
		'_content',
	  ],
     ]],
];

our $deltainfo = [
    'deltainfo' =>
      [ $deltapackage ],
];

our $prestodelta = [
    'prestodelta' =>
      [ $deltapackage ],
];

our $sourcediff = [
    'sourcediff' =>
	'key',
      [ 'old' =>
	    'project',
	    'package',
	    'rev',
	    'srcmd5',
      ],
      [ 'new' =>
	    'project',
	    'package',
	    'rev',
	    'srcmd5',
      ],
      [ 'files' =>
	 [[ 'file' =>
		'state',	# added, deleted, changed
	      [ 'old' =>
		    'name',
		    'md5',
		    'size',
		    'mtime',
	      ],
	      [ 'new' =>
		    'name',
		    'md5',
		    'size',
		    'mtime',
	      ],
	      [ 'diff' =>
		    'binary',
		    'lines',
		    'shown',
		    '_content',
              ],
         ]],
      ],
      [ 'issues' =>
	 [[ 'issue' =>
		'state',
		'issue-tracker',
		'name',
		'long-name',
		'show-url',
	 ]]
      ],
];

our $issue_trackers = [
    'issue-trackers' =>
     [[ 'issue-tracker' =>
	    [],
	    'name',
	    'description',
	    'kind',
            'long-name',
            'enable-fetch',
	    'regex',
	    'user',
#	    'password',    commented out on purpose, should not reach backend
	    'show-url',
	    'url',
            'issues-updated',
     ]],
];

1;
