/********************************************************************************
 *                                                                              *
 *  (c) Copyright 2012 Michal Stekrt 						*
 *                                                                              *
 *  This software is freely distributed in accordance with                      *
 *  the GNU Lesser General Public (LGPL) license, version 3 or later            *
 *  as published by the Free Software Foundation.                               *
 *  For details see LGPL: http://www.fsf.org/licensing/licenses/lgpl.html       *
 *               and GPL: http://www.fsf.org/licensing/licenses/gpl-3.0.html    *
 *                                                                              *
 *  This software is provided by the copyright holders and contributors "as is" *
 *  and any express or implied warranties, including, but not limited to, the   *
 *  implied warranties of merchantability and fitness for a particular purpose  *
 *  are disclaimed. In no event shall the copyright owner or contributors be    *
 *  liable for any direct, indirect, incidental, special, exemplary, or         *
 *  consequential damages (including, but not limited to, procurement of        *
 *  substitute goods or services; loss of use, data, or profits; or business    *
 *  interruption) however caused and on any theory of liability, whether in     *
 *  contract, strict liability, or tort (including negligence or otherwise)     *
 *  arising in any way out of the use of this software, even if advised of the  *
 *  possibility of such damage.                                                 *
 *                                                                              *
 ********************************************************************************/


package org.compendiumng.tools;

import java.awt.event.ActionEvent;
import java.util.Hashtable;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/*
 * http://weblogs.java.net/blog/ahashim/archive/2008/07/aspectj_please.html
 */
public aspect LoggingAspect {
	long entry_time = 0;
	long exit_time = 0;
	
	/** logger for LoggingAspect.class */
	final Logger log = LoggerFactory.getLogger(getClass());
	
	pointcut sysout():call(* java.io.PrintStream.print*(..));
	
	declare warning:sysout():"Don't use SYSOUT";
	
	after():sysout() {
		log.debug(thisJoinPoint.getArgs()[0].toString() + thisJoinPoint.getSourceLocation());
	}
	
	pointcut psexec(): call(* java.sql.PreparedStatement.execute*(..)) || call(* java.sql.PreparedStatement.executeUpdate*(..));
	
	pointcut psprepare():call(* *.prepareStatement(..));
		
	before():psprepare(){
		String location = thisJoinPoint.getSourceLocation().toString();
		String sqlcmd = thisJoinPoint.getArgs()[0].toString();
		log.debug("SQL @({}): {}", location, sqlcmd);
	}

	pointcut actionperformed(): execution(* *.actionPerformed(..));
	
	pointcut componentResized(): execution(* *.componentResized(..));
	
	before():actionperformed(){
		ActionEvent e = (ActionEvent)(thisJoinPoint.getArgs()[0]);
		String location = thisJoinPoint.getSourceLocation().getFileName();
		String THIS = thisJoinPoint.toShortString();
		String target = thisJoinPoint.getSignature().toShortString();
		String source = thisJoinPoint.getSignature().toShortString();
		log.debug("ENTRY: paramString: {} action @({}) this {} source {} target {}", e.paramString(), location, THIS, source, target);
		entry_time = System.currentTimeMillis();
		
	}
	
	after(): actionperformed() {
		ActionEvent e = (ActionEvent)(thisJoinPoint.getArgs()[0]);
		String location = thisJoinPoint.getSourceLocation().getFileName();
		String THIS = thisJoinPoint.toLongString();
		String target = thisJoinPoint.getSignature().toShortString();
		String source = thisJoinPoint.getSignature().toShortString();
		log.debug("EXIT: paramString: {} action @({}) this {} source {} target {}", e.paramString(), location, THIS, source, target);
		exit_time = System.currentTimeMillis();
		
		// check the time spend int the handler
		
		
		long duration = exit_time - entry_time;
		
		if (duration > 500) {
			log.error("DURATION[ms]: {} action @({}) this {} source {} target {}", duration, location, THIS, source, target);
		}
			
			
	}
	
}