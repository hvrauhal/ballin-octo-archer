(ql:quickload '(usocket cl-json babel))

(defun udp-handler (buffer) 
  (declare (type (simple-array (unsigned-byte 8) *) buffer))
  (format t "Got a packet~A~%From~A:~A" (json-octets-to-alist buffer) usocket:*remote-host* usocket:*remote-port*)
  (defparameter *n-packages* (1+ *n-packages*))
  (alist-to-json-octets '((type . pong) (connection-id . "abcdef"))))

(defun alist-to-json-octets (an-alist)
  (babel:string-to-octets (json:encode-json-alist-to-string an-alist) :encoding :utf-8))

(defun json-octets-to-alist (octets) 
  (let ((a-the-json-string (babel:octets-to-string octets :encoding :utf-8)))
    (json:decode-json-from-string a-the-json-string)))

(defun create-client (port)
  (let ((socket (usocket:socket-connect "127.0.0.1" port
					 :protocol :datagram
					 :element-type '(unsigned-byte 8))))
    (unwind-protect
	 (progn
	   (format t "Sending data~%")
           (let ((octet-array (alist-to-json-octets '((ping . pong)))))
             (usocket:socket-send socket octet-array 17))
	   (format t "Receiving data~%")
	   (multiple-value-bind (return-buffer return-length remote-host remote-port)
               (usocket:socket-receive socket nil 65507)
             (format t "Got obj ~A~%" (json-octets-to-alist return-buffer))
             (usocket:socket-close socket))))))

(create-client 12321)
