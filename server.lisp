(ql:quickload '(usocket cl-json babel))


(defun real-udp-handler (buffer)
  (declare (type (simple-array (unsigned-byte 8) *) buffer))
  (format t "Got a packet: ~A~%From ~A:~A~%" (json-octets-to-alist buffer) usocket:*remote-host* usocket:*remote-port*)
  (alist-to-json-octets '((type . pong) (connection-id . "abcdef"))))

(defun udp-handler-handle (buffer) 
  (real-udp-handler buffer))

(defun alist-to-json-octets (an-alist)
  (babel:string-to-octets (json:encode-json-alist-to-string an-alist) :encoding :utf-8))

(defun json-octets-to-alist (octets) 
  (let ((a-the-json-string (babel:octets-to-string octets :encoding :utf-8)))
    (json:decode-json-from-string a-the-json-string)))

(let* ((sample-original-alist '((type . pong) (connection-id . "abcdefg")))
       (sample-octets (alist-to-json-octets sample-original-alist))
       (sample-as-alist (json-octets-to-alist sample-octets)))
  (cdr (assoc :type sample-as-alist)))

(sb-thread:make-thread 
 #'(lambda (standard-output)
     (let ((*standard-output* standard-output))
       (format t "Starting the server...")
       (usocket:socket-server "127.0.0.1" 12321 #'udp-handler-handle nil :protocol :datagram)
       (format t "Server done.")))
 :arguments (list *standard-output*))
