Why you might need a proxy?
===========================

Synopsis
--------

When you try to load external datas into your Flash application (images, xml and so on) you
may have the cross domain issue (where the player won't pull data from a domain which doesn't
have a `cross domain policy <http://www.adobe.com/devnet/articles/crossdomain_policy_file_spec.html>`_
allowing them to do so). As OpenScales works with external datas like KML, WFS, WMS, images...
cross domain policy is the key of your GIS applications.

When should you use a proxy?
----------------------------

When you cannot get a valid cross domain policy the solution may be a proxy that will allow
you to by pass cross domain issue. This may be acomplished using a simple php script exposed by
a webserver like Apache:

.. code-block:: php5

	<?php
	  $url = (isset($_POST['url'])) ? $_POST['url'] : $_GET['url'];
	  // Open the Curl session
	  $session = curl_init($url);
	
	  // If it's a POST, put the POST data in the body
	  if (isset($_POST['url'])) {
	    $postvars = '';
	    while ($element = current($_POST)) {
	      $postvars .= key($_POST).'='.$element.'&';
	      next($_POST);
	    }
	    curl_setopt ($session, CURLOPT_POST, true);
	    curl_setopt ($session, CURLOPT_POSTFIELDS, $postvars);
	  }
	
	  // Don't return HTTP headers. Do return the contents of the call
	  curl_setopt($session, CURLOPT_HEADER, false);
	  curl_setopt($session, CURLOPT_CONNECTTIMEOUT, 10);
	  curl_setopt($session, CURLOPT_RETURNTRANSFER, true);
	  curl_setopt($session, CURLOPT_PROXY, 'proxy-middle:3128');
	  
	  // Make the call
	  $response = curl_exec($session);
	  
	  // if error, print and exit
	  if (curl_errno($session)) {
	    echo curl_error($session);
	    exit();
	  }
	  
	  // get mime type of the reponse, or, if none, get "default" one
	  $mimeType = curl_getinfo($session,CURLINFO_CONTENT_TYPE);
	  if($mimeType=='') {
	    $mimeType =(isset($_GET['FORMAT'])) ? $_GET['FORMAT'] : 'text/xml';
	  }
	
	  // Set the Content-Type appropriately
	  header('Content-Type: '.$mimeType);
	  
	  echo $response;
	  curl_close($session);
	?>

Now when you want to access http://foo.com/data.ext you access http://yourserver.com/proxy.php?url=http://foo.com/data.ext

Obviously, yourserver.com must have a valid cross domain policy. Moreover, make sure to restrict
this proxy to allowed IP only or to a specific list of domains.

