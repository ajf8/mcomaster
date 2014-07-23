mcomaster is a web frontend to MCollective, a message oriented ruby application server.

http://www.mcomaster.org/

Features
========================

*   Fast discovery of nodes by using MCollective registration agents and redis.
*   Filter by facts, identities, classes and agents.
*   Results are displayed as they arrive using AJAX.
*   Aggregates and statistics.
*   Validate request inputs in realtime.
*   CSV and JSON export of results.
*   Possible to extend with applications (experimental) like mcollective.
*   Results pagination.

System requirements
========================

*   Redis.
*   Ruby - should work on 1.9.x and 2.0
*   Bundler (to install dependencies).
*   MCollective client already configured.

Install
========================

See the INSTALL.md file.

Testing without Installation
==========================

See the VAGRANT.md file.

License
========================

Apache 2.0. See the LICENSE file for details.
