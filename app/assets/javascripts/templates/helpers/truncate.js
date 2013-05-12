/* Copyright 2013 ajf http://github.com/ajf8
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
Handlebars.registerHelper ( 'truncate', function ( str, len ) {

    if (str.length > len) {
        var new_str = str.substr ( 0, len+1 );

        while ( new_str.length )
        {
            var ch = new_str.substr ( -1 );
            new_str = new_str.substr ( 0, -1 );

            if ( ch == ' ' )
            {
                break;
            }
        }

        if ( new_str == '' )
        {
            new_str = str.substr ( 0, len );
        }

        return new Handlebars.SafeString ( new_str +'...' );
    }
    return str;
} );