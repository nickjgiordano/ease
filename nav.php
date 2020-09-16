<!DOCTYPE html>
<html>
	<head></head>
	<body>
		<?php $db = mysqli_connect('localhost', 'root', '', 'ease') or die('Database connection failed!'); // connect to database ?>
		<div class="top"><div class="top_info">
			<div class="left">EASE Ltd. &nbsp;|&nbsp;  Database Version 1.0</div><div class="right"><?php echo date('l jS F Y'); // display today's date ?></div>
		</div></div>
		<div class="logo"><a onclick="storePosition()" href="index.php"><img src="images/logo.png"></a></div>
		<?php
			// get list of table views to create array
			$result = mysqli_query($db, 'SHOW tables;');
			$views = array();
			while( $row = mysqli_fetch_row($result) ) {
				$viewname = $row[0];
				if(substr($viewname, 0, 2) == 'v_') {
					$viewname = ucwords( str_replace('_', ' ', $viewname) ); // remove underscores to capitalise word starts
					array_push( $views, substr(str_replace(' ', '_', $viewname), 2) ); // replace underscores and remove prefix
				}
			}
			// create menu items containing view names
			echo '<div class="menu"><div class="separator"></div>';
			for($i = 0 ; $i < count($views) ; $i++) {
				echo '<a onclick="storePosition()" href="index.php?view='.$views[$i].'"><div class="menu_item';
				if (isset($_REQUEST['view']) && $_REQUEST['view'] == $views[$i]) {echo '_selected';}
				echo '">'.ucwords( str_replace('_', ' ', $views[$i]) ).'</div></a><div class="separator"></div>';
			} echo '</div>';
		?>
		<div class="social">
			<a target="_blank" href="http://www.twitter.com"><img src="images/twitter.png"></a><br />
			<a target="_blank" href="http://www.instagram.com"><img src="images/instagram.png"></a><br />
			<a target="_blank" href="http://www.facebook.com"><img src="images/facebook.png"></a><br />
			<a target="_blank" href="http://www.youtube.com"><img src="images/youtube.png"></a><br />
			<a target="_blank" href="http://www.plus.google.com"><img src="images/googleplus.png"></a><br />
			<a target="_blank" href="http://www.linkedin.com"><img src="images/linkedin.png"></a><br />
		</div>
		<div class="footer">Copyright © 2019 &nbsp;|&nbsp;  EASE Ltd. &nbsp;|&nbsp;  All rights reserved </div>
	</body>
</html>