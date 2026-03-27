FROM mwaeckerlin/very-base AS build
RUN $PKG_INSTALL python3
RUN for file in \
    /usr/bin/python \
    /usr/lib/python* \
    $(for f in /usr/bin/python $(find /usr/lib/python* -name '*.so*'); do ldd $f; done 2> /dev/null | sed -n 's,.* \([^ ]*/lib/[^ ]*\) .*,\1,p' | sort | uniq); \
    do \
    path=${file%/*}; \
    test -d /tmp/root/$path || mkdir -p /tmp/root/$path; \
    cp -La $file /tmp/root/$file; \
    done

FROM mwaeckerlin/scratch
ENV CONTAINERNAME    "python"
ENV PATH             ""
ENTRYPOINT ["/usr/bin/python"]
CMD ["main.py"]
USER "${RUN_USER}"
WORKDIR /app
COPY --from=build /tmp/root /
