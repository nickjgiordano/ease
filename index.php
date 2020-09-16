<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">
		<script type="text/javascript" src="script.js"></script>
		<link rel="stylesheet" type="text/css" href="style.css">
		<link rel="shortcut icon" type="image/x-icon" href="images/favicon.png">
		<title>Database | EASE Ltd.</title>
	</head>
	<body onload="scrollPosition()">
		<?php
			require_once('nav.php');
			// if view is set, create table page; otherwise display homepage with welcome message
			if( isset($_REQUEST['view']) ) {
				$view = "v_".$_REQUEST['view']; // set view variable to have view prefix
				// select data to get info on hyperlink and number of rows and columns
				$result = mysqli_query($db, "SELECT * FROM $view;") or die("Error! Can't load data!");
				$nrows = mysqli_num_rows($result);
				$ncolumns = mysqli_num_fields($result);
				$result = mysqli_query($db, "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$view';") or die("Error! Can't load data!");
				$linkcode;
				$linktable;
				$linkfilter;
				$hide = 0;
				while( $row = mysqli_fetch_row($result) ) {
					if(substr($row[0], 0, 5) == 'link_') {
						$linkcode = $row[0];
						$position = strrpos($linkcode, '__');
						$linkfilter = substr($linkcode, $position+2);
						$linktable = str_replace( '__'.$linkfilter, '', substr($linkcode, 5) );
						$hide++;
					} else if (substr($row[0], 0, 5) == 'hide_') {$hide++;}
				}
				$ncolumns -= $hide;
				// select data for page display, using filter and sort preferences
				$query = "SELECT * FROM $view";
				if( isset($_REQUEST['filter']) ) {
					$filter = $_REQUEST['filter'];
					$criterion = $_REQUEST['criterion'];
					$query = "$query WHERE $filter = '$criterion'";
				}
				if( isset($_REQUEST['sort']) ) {
					$sort = $_REQUEST['sort'];
					$order = $_REQUEST['order'];
					$query = "$query ORDER BY $sort $order";
				} else {$query = "$query ORDER BY ID";}
				$result = mysqli_query($db, $query.';') or die("Error! Can't load data!");
				// create select list row for filtering
				echo '<br /><table class="data"><tr><td colspan="'.$ncolumns.'" class="radius_top"></td></tr><tr class="filter">';
				while( $col = mysqli_fetch_field($result) ) {
					$colname = $col->name;
					if(substr($colname, 0, 5) != 'link_' && substr($colname, 0, 5) != 'hide_') {
						$coltype = $col->type;
						$result_list = mysqli_query($db, "SELECT $colname FROM $view GROUP BY $colname ORDER BY $colname ASC;")
						or die("Error! Can't load data!");
						echo '<td><select id="filter" onchange="filter(\''.str_replace('v_', '', $view).'\', \''.$colname.'\', this)">';
						echo '<option value="'.$colname.'">'.str_replace('_', ' ', str_replace('bool_', '', $colname) ).'</option>';
						mysqli_data_seek($result_list, 0);
						while( $row = mysqli_fetch_assoc($result_list) ) {
							$data = $row[$colname];
							$value = $data;
							if($coltype == 1) { if($value) {$data = 'yes';} else if(!$value) {$data = 'no';} }
							echo '<option value="'.$value.'">'.$data.'</option>';
						} echo '</select></td>';
					}
				}
				// create sort link row for sorting
				echo '</tr><tr class="sort">';
				mysqli_field_seek($result, 0);
				while( $col = mysqli_fetch_field($result) ) {
					$colname = $col->name;
					if(substr($colname, 0, 5) != 'link_' && substr($colname, 0, 5) != 'hide_') {
						echo '<td><a onclick="storePosition()" href="index.php?view='.urlencode( str_replace('v_', '', $view) );
						if (isset($_REQUEST['filter']) && $filter == $colname)
						{echo '"><div class="clear_x">x';}
						else {
							if( isset($filter) ) {echo '&filter='.urlencode($filter).'&criterion='.urlencode($criterion);}
							echo '&sort='.urlencode($colname).'&order=';
							if(isset($sort) && $sort == $colname && $order == 'ASC') {echo 'DESC"><div>&#x25B2;';}
							else if(isset($sort) && $sort == $colname && $order == 'DESC') {echo 'ASC"><div>&#x25BC;';}
							else {echo 'ASC"><div>&#x25AC;';}
						} echo '</div></a></td>';
					}
				} echo '</tr>';
				// populate table with data, looping through rows
				while( $row = mysqli_fetch_assoc($result) ) {
					echo '<tr class="row">';
					$link = $row[$linkcode];
					mysqli_field_seek($result, 0);
					while ( $col = mysqli_fetch_field($result) ) {
						$colname = $col->name;
						if(substr($colname, 0, 5) != 'link_' && substr($colname, 0, 5) != 'hide_') {
							$coltype = $col->type;
							$data = $row[$colname];
							if($coltype == 1 || substr($colname, 0, 5) == 'bool_') {
								if($data) {echo '<td class="col_yes"><a href="index.php?view='.urlencode($linktable).'&filter='.$linkfilter.'&criterion='.$link.'"><div class="cell">&#x2714;</div></a></td>';}
								else if(!$data) {echo '<td class="col_no"><a href="index.php?view='.urlencode($linktable).'&filter='.$linkfilter.'&criterion='.$link.'"><div class="cell">&#x2718;</div></a></td>';}
							}
							else if($coltype < 10) { echo '<td class="col_right"><a href="index.php?view='.urlencode($linktable).'&filter='.$linkfilter.'&criterion='.$link.'"><div class="cell">'.$data.'</div></a></td>'; }
							else if($coltype == 246) { echo '<td class="col_right"><a href="index.php?view='.urlencode($linktable).'&filter='.$linkfilter.'&criterion='.$link.'"><div class="cell">£'.$data.'</div></a></td>'; }
							else { echo '<td class="column"><a href="index.php?view='.urlencode($linktable).'&filter='.$linkfilter.'&criterion='.$link.'"><div class="cell">'.$data.'</div></a></td>'; }
						}
					} echo '</tr>';
				}
				// create table footer
				$nrows_filter = mysqli_num_rows($result);
				echo '<tr><td colspan="'.$ncolumns.'" class="empty_row">&nbsp;</td></tr>' .
				'<tr class="table_footer"><td colspan ="'.$ncolumns.'" class="table_info">Displaying '.$nrows_filter.' of '.$nrows.' record(s)';
				if( isset($filter) ) {
					$filter_label = str_replace( '_', ' ', str_replace('bool_', '', $filter) );
					if($filter_label == 'hide ') {$filter_label = 'ID';}
					echo ' &nbsp; | &nbsp; <span>filtered by '.$filter_label.' = '.$criterion.'</span>' .
					' &nbsp; | &nbsp; <a onclick="storePosition()" href="index.php?view='.urlencode( str_replace('v_', '', $view) ).'" class="clear">clear filter</a>';
				} echo '</td></tr><tr><td colspan="'.$ncolumns.'" class="radius_bottom">&nbsp;</td></tr></table>';
				// free results and close database
				if( isset($result_list) ) {mysqli_free_result($result_list);}
				mysqli_free_result($result);
				mysqli_close($db);
			} else {
				echo '<div class="content_wrapper"><div class="content">' .
				'<h1 style="text-align: center;">EASE Ltd.</h1><h4 style="text-align: center;">Database Version 1.0</h4><hr style="color: #b366cc; width: 50px;" />' .
				'<p>Welcome to the EASE Database! Click the links above to navigate the different views!</p>' .
				'<h2 style="padding-top: 10px;">Table view descriptions</h2>' .
				'<p>The <span style="font-weight: bold;">Supplier</span> view contains all of the company\'s suppliers, along with their contact details. It also displays the branches that each supplies.</p>' .
				'<p>The <span style="font-weight: bold;">Branch</span> view contains all of the company\'s branches, along with our contact details.</p>' .
				'<p>The <span style="font-weight: bold;">Employee</span> view contains all the company\'s employees, along with their contact details. It also displays the branch at which each is employed.</p>' .
				'<p>The <span style="font-weight: bold;">Customer</span> view contains all the company\'s customers, along with their contact details.</p>' .
				'<p>The <span style="font-weight: bold;">Room</span> view contains all of the company\'s standard and executive rooms across its different branches, along with details about room sizes and prices.</p>' .
				'<p>The <span style="font-weight: bold;">Room Booking</span> view contains individual bookings made on each room. Information is provided on customers, dates and times, the rooms themselves, and booking preferences.</p>' .
				'<p>The <span style="font-weight: bold;">Booking</span> view contains complete bookings made by customers, including the number of rooms located within, and total cost.</p>' .
				'</div></div>';
			}
		?>
	</body>
</html>