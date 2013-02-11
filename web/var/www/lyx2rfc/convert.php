<?php
class Converter {
	const SCRIPT = '/var/local/lyx2rfc/lyx2rfc-master/src/lyx2rfc';
	const TMP_DIR = '/tmp';

	private function report_error($msg) {
		echo("<p style='color:red'>".$msg."</p>");
		exit(1);
	}

	private function convert_files($infile_name, &$outfile_name) {
		$home = getenv('HOME');
		if (empty($home)) { // which freaks LyX out
			putenv('HOME='.sys_get_temp_dir());
		}
		$command = self::SCRIPT . ' ' . $infile_name . ' ' . $outfile_name;
		$command = escapeshellcmd($command); // just in case
		// echo "run: $command\n";
		exec($command, $output, $status); // swallows stdout into $output
		if ($status != 0) {
			$this->report_error("Conversion failed");
		}
	}

	public function change_suffix($infile_name, $suff) {
		$path_parts = pathinfo($infile_name);
		if ($path_parts['dirname']) {
			$outfile_name = $path_parts['dirname'] . '/' . $path_parts['filename'] . '.' . $suff;
		} else {
			$outfile_name = $path_parts['filename'] . '.' . $suff;
		}
		return $outfile_name;
	}

	public function convert($format, $infile_name, &$outfile_name) {
		switch ($format) {
		case 'text':
			$outfile_name = $this->change_suffix($infile_name, 'txt');
			$this->convert_files($infile_name, $outfile_name);
			break;
		case 'html':
			$outfile_name = $this->change_suffix($infile_name, 'html');
			$this->convert_files($infile_name, $outfile_name);
			break;
		case 'xml':
			$outfile_name = $this->change_suffix($infile_name, 'xml');
			$this->convert_files($infile_name, $outfile_name);
			break;
		default:
			echo "Convert to what format?\n";
		}
	}
}

function usage($script) {
	echo "Usage: $script text/html/xml source_file\n";
}

if (isset($argc)) { // running from CLI
	if ($argc != 3) {
		usage($argv[0]);
		exit(1);
	}
	$format = $argv[1];
	$infile_name = $argv[2];
	$converter = new Converter();
	$converter->convert($format, $infile_name, $outfile_name);
	echo "Output written to ".$outfile_name."\n";
} else { // called for form submission
	$format = $_POST['format'];
	$rendertype = $_POST['rendertype'];
	$orig_file_name = $_FILES['uploadedFile']['name'];
	$tmp_name = $_FILES['uploadedFile']['tmp_name'];
	if (empty($orig_file_name)) {
		echo("<p style='color:red'>No file uploaded!</p>");
		exit(1);
	}
	if (strtolower(pathinfo($orig_file_name, PATHINFO_EXTENSION)) != 'lyx') {
		echo("<p style='color:red'>This ain't no LyX file!</p>");
		exit(1);
	}
	$infile_name = $tmp_name . '.lyx';
	rename($tmp_name, $infile_name);
	// echo "Hi! $format $rendertype $orig_file_name $tmp_name\n";
	$converter = new Converter();
	$converter->convert($format, $infile_name, $outfile_name);
	switch ($format) {
		case 'text':
			$fname = $converter->change_suffix($orig_file_name, 'txt');
			header("Content-Type: text/plain");
			break;
		case 'html':
			$fname = $converter->change_suffix($orig_file_name, 'html');
			header("Content-Type: text/html");
			break;
		case 'xml':
			$fname = $converter->change_suffix($orig_file_name, 'xml');
			header("Content-Type: text/xml");
			break;
	}
	if ($rendertype == 'file') {
		header('Content-Disposition: attachment; filename="'.$fname.'"');
	}
	readfile($outfile_name);
	unlink($outfile_name);
}
?>
