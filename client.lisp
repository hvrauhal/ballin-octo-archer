(ql:quickload '(usocket cl-json babel))

(defparameter *debug* nil)

(defun alist-to-json-octets (an-alist)
  (let ((json-string (json:encode-json-alist-to-string an-alist)))
    (if *debug* (format t "JSON string ~A~%" json-string))
    (babel:string-to-octets json-string :encoding :utf-8)))

(defun json-octets-to-alist (octets) 
  (let ((a-the-json-string (babel:octets-to-string octets :encoding :utf-8)))
    (json:decode-json-from-string a-the-json-string)))

(defun udp-handler (buffer) 
  (declare (type (simple-array (unsigned-byte 8) *) buffer))
  (format t "Got a packet~A~%From~A:~A" (json-octets-to-alist buffer) usocket:*remote-host* usocket:*remote-port*)
  (defparameter *n-packages* (1+ *n-packages*))
  (alist-to-json-octets '((type . pong) (connection-id . "abcdef"))))

(defun ip-addr-array-to-string (address-array) (format nil "~{~A~^.~}" (coerce address-array 'list)))

(defparameter *run-client* nil)

(defun read-welcome-msg (socket)
  (multiple-value-bind (return-buffer return-length remote-host remote-port)
      (usocket:socket-receive socket nil 65507)
    (let ((welcome-msg-alist (json-octets-to-alist return-buffer)))
      
      (format t "C: Got welcome msg foo ~A~%" welcome-msg-alist)
      socket)))

(defun create-client (server-host server-port)
  (let ((socket (usocket:socket-connect server-host server-port
					 :protocol :datagram
					 :element-type '(unsigned-byte 8))))
    (unwind-protect
	 (progn
	   (format t "C: Sending data~%")
           (let* ((list-to-send (list (cons 'type 'connect) (cons 'address (ip-addr-array-to-string (usocket:get-local-address socket))) (cons 'port (usocket:get-local-port socket))))
                  (octet-array (alist-to-json-octets list-to-send))
                  (length-of-octet-array (array-total-size octet-array)))
             (usocket:socket-send socket octet-array length-of-octet-array))
           (let ((game-socket (read-welcome-msg socket)))
             (loop while *run-client*
                do (progn 
                     (format t "C: Receiving data~%")
                     (multiple-value-bind (return-buffer return-length remote-host remote-port)
                         (usocket:socket-receive socket nil 65507)
                       (format t "C: Got obj ~A~%" (json-octets-to-alist return-buffer)))))))
      (usocket:socket-close socket))))
  
(create-client "127.0.0.1" 12321)
  
; {"type":"connect","address":"127.0.0.1","port":12321}
